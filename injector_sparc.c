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
      { 0x00, 0x00, 0x00, 0x00 }, .len = 0, .index = 0 }, .end =
    { .bytes =
      { 0xff, 0xff, 0xff, 0xff }, .len = 0, .index = 2 ^ 32 }, .started =
  false };

void
initialize ()
{
#if defined(START3)
  search_range.start.bytes[3] = (uint8_t)START3;
#endif
#if defined(START2)
  search_range.start.bytes[2] = (uint8_t)START2;
#endif
#if defined(START1)
  search_range.start.bytes[1] = (uint8_t)START1;
#endif
#if defined(START0)
  search_range.start.bytes[0] = (uint8_t)START0;
#endif
#if defined(END3)
  search_range.end.bytes[3] = (uint8_t)END3;
#endif
#if defined(END2)
  search_range.end.bytes[2] = (uint8_t)END2;
#endif
#if defined(END1)
  search_range.end.bytes[1] = (uint8_t)END1;
#endif
#if defined(END0)
  search_range.end.bytes[0] = (uint8_t)END0;
#endif
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
  unsigned char *pc = (unsigned char*) addr;

  // Output description if given.
  if (desc != NULL)
    printf ("%s: ", desc);

  // Process every byte in the data.
  for (i = 0; i < len; i++)
    {
      printf (" %02x", pc[i]);
    }
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

  printf ("  0x%02x\n", trap_number);

  switch (trap_number)
    {
    case 0x02:
      //trap_totals.illegal_instruction++;
      break;
    default:
      break;
    }
}

int
main ()
{
  initialize ();

  packet_buffer = malloc (INSN_SIZE * 10);

  bcc_set_trap (0x02, &fault_handler);

  while (move_next_instruction ())
    {
      inject ();
      hexDump ("Instruction", packet, 4);
      handle_result ();
    }

  puts ("Search finished!");
  return (EXIT_SUCCESS);
}
