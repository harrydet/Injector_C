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

extern int resume, postamble_start, postamble_end, _init;

void* packet_buffer;
char* packet;
void* result;

bool trap_occured;

uint32_t tbr_value;
uint32_t tbr_from_lib;

typedef struct
{
  uint8_t bytes[MAX_INS_LENGTH];
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
      { 0x00, 0x00, 0x00, 0x00 }, .len = 0 }, .end =
    { .bytes =
      { 0xff, 0xff, 0xff, 0xff }, .len = 0 }, .started =
  false };

void
initialize ()
{
#if defined(START3)
  search_range.start.bytes[3] = (uint8_t) START3;
#endif
#if defined(START2)
  search_range.start.bytes[2] = (uint8_t) START2;
#endif
#if defined(START1)
  search_range.start.bytes[1] = (uint8_t) START1;
#endif
#if defined(START0)
  search_range.start.bytes[0] = (uint8_t) START0;
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
  trap_occured = true;
  __asm__ __volatile__("\
      			rett %[res]\n\
		       "
      :
      :[res]"r"(&resume));
}

void
set_trap_handlers ()
{
  bcc_set_trap (0x02, &fault_handler);
  bcc_set_trap (0x24, &fault_handler);
  bcc_set_trap (0x2b, &fault_handler);
  bcc_set_trap (0x3c, &fault_handler);
  bcc_set_trap (0x21, &fault_handler);
  bcc_set_trap (0x20, &fault_handler);
  bcc_set_trap (0x01, &fault_handler);
  bcc_set_trap (0x03, &fault_handler);
  bcc_set_trap (0x04, &fault_handler);
  bcc_set_trap (0x25, &fault_handler);
  bcc_set_trap (0x0b, &fault_handler);

  // Use default trap handlers for 0x05 and 0x06
  //bcc_set_trap (0x05, &fault_handler);
  //bcc_set_trap (0x06, &fault_handler);

  bcc_set_trap (0x07, &fault_handler);
  bcc_set_trap (0x08, &fault_handler);
  bcc_set_trap (0x28, &fault_handler);
  bcc_set_trap (0x29, &fault_handler);
  bcc_set_trap (0x2c, &fault_handler);
  bcc_set_trap (0x09, &fault_handler);
  bcc_set_trap (0x0a, &fault_handler);
  bcc_set_trap (0x2a, &fault_handler);
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
	  ins.bytes[3]++;
	  i = 1;
	}
      else if ((unsigned) ins.bytes[2] < search_range.end.bytes[2])
	{
	  ins.bytes[3] = 0;
	  ins.bytes[2]++;
	  i = 1;
	}
      else if ((unsigned) ins.bytes[1] < search_range.end.bytes[1])
	{
	  ins.bytes[3] = 0;
	  ins.bytes[2] = 0;
	  ins.bytes[1]++;
	  ;
	  i = 1;
	}
      else if ((unsigned) ins.bytes[0] < search_range.end.bytes[0])
	{
	  ins.bytes[3] = 0;
	  ins.bytes[2] = 0;
	  ins.bytes[1] = 0;
	  ins.bytes[0]++;

	  //Skip CALL instruction
	  if (ins.bytes[0] >= 4)
	    ins.bytes[0] = 8;
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
  if (trap_occured)
    {
      tbr_value = ((int) ((int*) result));
      tbr_from_lib = bcc_get_tbr ();

      //Mask important 8 bits and shift right to get rid of tail 0s
      printf ("  0x%02x", (uint) (tbr_value & TBR_MASK) >> 4);
      printf ("  0x%02x\n", (uint) (tbr_from_lib & TBR_MASK) >> 4);

      trap_occured = false;
    }
  else
    {
      printf ("  v\n");
    }

  __asm__ __volatile__ ("\
            			call %[i]   \n\
          			nop        \n\
            			"
      : // No output
      : [i]"r"(&_init)
  );

}

int
main ()
{
  //initialize ();
  set_trap_handlers ();

  packet_buffer = malloc (INSN_SIZE * 10);

  while (move_next_instruction ())
    {
      //trap_occured = false;

      inject ();
      hexDump (NULL, packet, 4);
      handle_result ();
    }

  puts ("Search finished!");
  return (EXIT_SUCCESS);
}
