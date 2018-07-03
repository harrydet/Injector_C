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
#include <bcc/bcc.h>

#define INSN_SIZE 32
#define MAX_INS_LENGTH 4

extern int resume;

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
      { 0x00, 0x00, 0xff, 0xff }, .len = 0, .index = 0 }, .end =
    { .bytes =
      { 0x00, 0xff, 0xff, 0xff }, .len = 0, .index = 2 ^ 32 }, .started =
  false };

typedef struct
{
  uint32_t illegal_instruction;
} trptbl_t;
trptbl_t trap_totals =
  { .illegal_instruction = 0
  };

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
  packet = packet_buffer;

  for (i = 0; i < MAX_INS_LENGTH; i++)
    {
      ((char*) packet)[i] = ins.bytes[i];
    }

  __asm__ __volatile__ ("\
  			jmp %%g1   \n\
			nop        \n\
			.global resume   \n\
			resume:          \n\
			mov %%tbr, %[result] \n\
  			"
      : [result]"=r"(result)
      : [p]"m"(*packet)
  );

//  __asm__ __volatile__("\
//			.global resume   \n\
//			resume:          \n\
//                       "
//		       :
//                       :);

}

void
handle_result (void)
{
  //hexDump ("\tTrap address", &result, 4);
  uint32_t trap_number = ((int) ((int*) result)) - 0x40000000;

  switch (trap_number)
    {
    case 0x20:
      trap_totals.illegal_instruction++;
      break;
    default:
      break;
    }
}

int
main (void)
{
  packet_buffer = malloc (INSN_SIZE);

  bcc_set_trap (0x02, &fault_handler);

  while (move_next_instruction ())
    {
      hexDump ("Instruction", packet, 4);
      inject ();
      handle_result ();
    }

  puts ("Search finished!");
  printf("Total illegal instructions: %d\n", trap_totals.illegal_instruction);
  return (EXIT_SUCCESS);
}
