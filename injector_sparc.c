/*
 ============================================================================
 Name        :
 Author      :
 Version     :
 Copyright   :
 Description :
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <getopt.h>
#include <bcc/bcc.h>

#define INSN_SIZE 32
#define MAX_INS_LENGTH 4
#define TBR_MASK 0xFF0

extern int resume, postamble_start, postamble_end;

void* packet_buffer;
char* packet;
void* result;

typedef struct
{
  uint8_t bytes[MAX_INS_LENGTH];
  double index;
  int len;
} ins_t;
ins_t ins;

typedef struct
{
  ins_t start;
  ins_t end;
  bool started;
} range_t;
range_t search_range =
  { .start =
    { .bytes =
      { 0x80, 0xa0, 0x60, 0x00 }, .len = 0, .index = 0 }, .end =
    { .bytes =
      { 0x00, 0xff, 0xff, 0xff }, .len = 0, .index = 2 ^ 32 }, .started =
  false };

typedef struct
{
  uint32_t illegal_instruction;
  uint32_t data_store_error;
  uint32_t instruction_access_MMU_miss;
  uint32_t instruction_access_error;
  uint32_t r_register_access_error;
  uint32_t instruction_access_exception;
  uint32_t priviledged_instruction;
  uint32_t fp_disabled;
  uint32_t cp_disabled;
  uint32_t unimplemented_FLUSH;
  uint32_t watchpoint_detected;
  uint32_t window_overflow;
  uint32_t window_underflow;
  uint32_t mem_address_not_aligned;
  uint32_t fp_exception;
  uint32_t cp_exception;
  uint32_t data_access_error;
  uint32_t data_access_MMU_miss;
  uint32_t data_access_exception;
  uint32_t tag_overflow;
  uint32_t division_by_zero;
  uint32_t other;
} trptbl_t;
trptbl_t trap_totals =
  { .illegal_instruction = 0, .data_store_error = 0,
      .instruction_access_MMU_miss = 0, .instruction_access_error = 0,
      .r_register_access_error = 0, .instruction_access_error = 0,
      .priviledged_instruction = 0, .illegal_instruction = 0, .fp_disabled = 0,
      .cp_disabled = 0, .unimplemented_FLUSH = 0, .watchpoint_detected = 0,
      .window_overflow = 0, .window_underflow = 0, .mem_address_not_aligned = 0,
      .fp_exception = 0, .cp_exception = 0, .data_access_error = 0,
      .data_access_MMU_miss = 0, .data_access_exception = 0, .tag_overflow = 0,
      .division_by_zero = 0, .other = 0 };

void
initialize (int argc, char** argv)
{
  int c;
  while ((c = getopt (argc, argv, "i:")) != -1)
    {
      switch (c)
	{
	case 'i':
	  puts ("Hi :)");
	}
    }
}

void
postamble (void)
{
  __asm__ __volatile__ ("\
  			.global postamble_start                    \n\
  			postamble_start:                           \n\
			sethi %%hi(resume), %%g1                   \n\
	                or %%g1, %%lo(resume), %%g1		   \n\
  			jmp %%g1                                   \n\
  			nop                                        \n\
  			.global postamble_end                      \n\
  			postamble_end:                             \n\
  			"
      : // No output
      : // No input
  );
}

void
hexDump (char *desc, void *addr, int len)
{
  int i;
  unsigned char buff[17];
  unsigned char *pc = (unsigned char*) addr;

  // Output description if given.
  if (desc != NULL)
    printf ("%s: ", desc);

  // Process every byte in the data.
  for (i = 0; i < len; i++)
    {
      printf (" %02x", pc[i]);

      // And store a printable ASCII character for later.
      if ((pc[i] < 0x20) || (pc[i] > 0x7e))
	{
	  buff[i % 16] = '.';
	}
      else
	{
	  buff[i % 16] = pc[i];
	}

      buff[(i % 16) + 1] = '\0';
    }

  // Pad out last line if not exactly 16 characters.
  while ((i % 16) != 0)
    {
      printf ("   ");
      i++;
    }

  // And print the final ASCII bit.
  printf ("  %s\n", buff);
}

void
fault_handler (void)
{
  __asm__ __volatile__("\
      			rett %[res]\n\
		       "
      :
      :[res]"r"(&resume));
}

bool
move_next_instruction (void)
{
  int i;

  if (!search_range.started)
    {
      ins = search_range.start;
      search_range.started = true;
      i = 1;
    }
  else
    {
      if (ins.bytes[3] < search_range.end.bytes[3])
	{
	  ins.index++;
	  ins.bytes[3]++;
	  i = 1;
	}
      else if ((unsigned) ins.bytes[2] < search_range.end.bytes[2])
	{
	  ins.index++;
	  ins.bytes[3] = 0;
	  ins.bytes[2]++;
	  i = 1;
	}
      else if ((unsigned) ins.bytes[1] < search_range.end.bytes[1])
	{
	  ins.index++;
	  ins.bytes[3] = 0;
	  ins.bytes[2] = 0;
	  ins.bytes[1]++;
	  ;
	  i = 1;
	}
      else if ((unsigned) ins.bytes[0] < search_range.end.bytes[0])
	{
	  ins.index++;
	  ins.bytes[3] = 0;
	  ins.bytes[2] = 0;
	  ins.bytes[1] = 0;
	  ins.bytes[0]++;
	  i = 1;
	}
      else
	{
	  i = 0;
	}
    }

  return i;
}

void
inject (void)
{

  int i;
  int a_start = (int) &postamble_start;
  int a_end = (int) &postamble_end;
  int postamble_length = a_end - a_start;
  packet = packet_buffer;

  for (i = 0; i < MAX_INS_LENGTH; i++)
    {
      ((char*) packet)[i] = ins.bytes[i];
    }

  for (i = 0; i < postamble_length; i++)
    {
      ((char*) packet)[i + MAX_INS_LENGTH] = ((char*) &postamble_start)[i];
    }

  __asm__ __volatile__ ("\
  			jmp %[p]   \n\
			nop        \n\
			.global resume   \n\
			resume:          \n\
			mov %%tbr, %[result] \n\
  			"
      : [result]"=r"(result)
      : [p]"r"(packet)
  );

}

void
handle_result (void)
{
  //hexDump ("\tTrap address", &result, 4);
  uint32_t tbr_value = ((int) ((int*) result));

  //Mask important 8 bits and shift right to get rid of tail 0s
  uint32_t trap_number = (tbr_value & TBR_MASK) >> 4;

  switch (trap_number)
    {
    case 0x02:
      trap_totals.illegal_instruction++;
      break;
    default:
      break;
    }
}

int
main (int argc, char** argv)
{
  initialize(argc, argv);

  packet_buffer = malloc (INSN_SIZE * 5);

  bcc_set_trap (0x02, &fault_handler);

  while (move_next_instruction ())
    {
      hexDump ("Instruction", packet, 4);
      inject ();
      handle_result ();
    }

  puts ("Search finished!");
  printf ("Total illegal instructions: %d\n", trap_totals.illegal_instruction);
  return (EXIT_SUCCESS);
}
