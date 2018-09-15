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
#include <limits.h>
#include <bcc/bcc.h>

#define INSN_SIZE 32
#define MAX_INS_LENGTH 4
#define TBR_MASK 0xFF0
#define LAST_INSTRUCTION UINT_MAX

#define ANNUL_MASK 0xE1C00000
#define ANNUL_TEMPLATE 0x20800000
#define ANNUL_COP_TEMPLATE 0x21800000
#define ANNUL_FLOAT_TEMPLATE 0x21C00000

#define SETHI_MASK 0xFFC00000
#define SP_TEMPLATE 0x3D000000
#define FP_TEMPLATE 0x3D200000
#define I7_TEMPLATE 0x3F000000

#define FORM3_MASK 0xC1F80000
#define TAG_ADD_TEMPLATE 0x81100000
#define TAG_SUB_TEMPLATE 0x81180000

#define WRY_TEMPLATE 0x81800000
#define WPSR_TEMPLATE 0x81880000
#define WRWIM_TEMPLATE 0x81900000
#define WRTBR_TEMPLATE 0x81980000

#define RESTORE_TEMPLATE 0x81E80000
#define SAVE_TEMPLATE 0x81E00000
#define JMP_TEMPLATE 0x81C00000
#define RETT_TEMPLATE 0x81C80000

#define UDIV_TEMPLATE 0x80700000
#define SDIV_TEMPLATE 0x80780000
#define UDIVC_TEMPLATE 0x80F00000
#define SDIVC_TEMPLATE 0x80F80000

#define TRAP_TEMPLATE 0x81D00000

#define SEARCH_FORWARD 1
#define SEARCH_BACK 2

extern int resume, postamble_start, postamble_end, _init, anchor_point;

void* packet_buffer;
char* packet;
void* result;

bool trap_occured;
int last_trap, cont_traps;

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
  int rate;
  uint32_t true_value;
  int direction;
  uint32_t last_switch;
} range_t;
range_t search_range =
  { .start =
    { .bytes =
      { 0x83, 0xc7, 0x77, 0x7c }, .len = 0 }, .end =
    { .bytes =
      { 0xff, 0xff, 0xff, 0xff }, .len = 0 }, .started =
  false, .rate = 1, .true_value = 0, .direction = SEARCH_FORWARD, .last_switch =
      0 };

void
convert_to_int (void)
{
  int i;
  search_range.true_value = 0;
  for (i = 0; i < MAX_INS_LENGTH; ++i)
    search_range.true_value = search_range.true_value * 256
	+ (uint8_t) ins.bytes[i];

//  search_range.true_value = ins.bytes[3];
//  search_range.true_value += ins.bytes[2] * UCHAR_MAX + 1;
//  search_range.true_value += ins.bytes[1] * (USHRT_MAX + 1);
//  search_range.true_value += ins.bytes[0] * ((UCHAR_MAX + 1) * (USHRT_MAX + 1));
}

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

  int i;
  for (i = 0; i < MAX_INS_LENGTH; ++i)
    ins.bytes[i] = search_range.start.bytes[i];

  convert_to_int ();
}

void
postamble (void)
{
  __asm__ __volatile__ ("\
  			.global postamble_start                    \n\
  			postamble_start:                           \n\
			ta 0x88				   	   \n\
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
    printf ("%s", desc);

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

  bcc_set_trap (0x88, &fault_handler);
}

void
convert_to_bytes (void)
{
  ins.bytes[0] = (search_range.true_value >> 24) & 0xff;
  ins.bytes[1] = (search_range.true_value >> 16) & 0xff;
  ins.bytes[2] = (search_range.true_value >> 8) & 0xff;
  ins.bytes[3] = search_range.true_value & 0xff;
}

bool
move_next_instruction (void)
{
  int i;

  if (!search_range.started)
    {
      convert_to_int ();
      ins = search_range.start;
      search_range.started = true;
      i = 1;
    }
  else
    {
      i = 1;
      int multiplier;
      if (search_range.direction == SEARCH_FORWARD)
	multiplier = 1;
      else
	multiplier = -1;

      if (__builtin_add_overflow (search_range.true_value,
				  search_range.rate * multiplier,
				  &search_range.true_value))
	{
	  if (search_range.rate > 1)
	    {
	      convert_to_int ();
	      search_range.rate = 1;
	      cont_traps = 0;
	    }
	  else
	    {
	      i = 0;
	    }
	}
      else
	{
	  convert_to_bytes ();
	  __asm__ __volatile__ ("\
	              			.global anchor_point \n\
	            			anchor_point:        \n\
	              			"
	      : // No output
	      :// No input
	  );
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

  i = *(uint32_t*) packet;
  if ((i & ANNUL_MASK) == ANNUL_TEMPLATE
      || (i & ANNUL_MASK) == ANNUL_COP_TEMPLATE
      || (i & ANNUL_MASK) == ANNUL_FLOAT_TEMPLATE)
    {
      printf ("Annul, skipping ");
      __asm__ __volatile__ ("\
    			 st %[value], %[result] \n\
    			  "
	  : // No output
	  : [result]"m"(result),
	  [value]"r"(0x40000880));
      return;
    }

  if ((i & SETHI_MASK) == SP_TEMPLATE || (i & SETHI_MASK) == FP_TEMPLATE
      || (i & SETHI_MASK) == I7_TEMPLATE)
    {
      printf ("SETHI to control flow, skipping ");
      __asm__ __volatile__ ("\
          			 st %[value], %[result] \n\
          			  "
	  : // No output
	  : [result]"m"(result),
	  [value]"r"(0x40000880));
      return;
    }

  if ((i & FORM3_MASK) == TAG_ADD_TEMPLATE || (i & FORM3_MASK) == TAG_SUB_TEMPLATE)
    {
      printf ("Tagged ADD or SUB, skipping ");
      __asm__ __volatile__ ("\
                			 st %[value], %[result] \n\
                			  "
	  : // No output
	  : [result]"m"(result),
	  [value]"r"(0x40000880));
      return;
    }

  if ((i & FORM3_MASK) == WRY_TEMPLATE || (i & FORM3_MASK) == WPSR_TEMPLATE
      || (i & FORM3_MASK) == WRWIM_TEMPLATE || (i & FORM3_MASK) == WRTBR_TEMPLATE)
    {
      printf ("Write to special registers, skipping ");
      __asm__ __volatile__ ("\
                  			 st %[value], %[result] \n\
                  			  "
	  : // No output
	  : [result]"m"(result),
	  [value]"r"(0x40000880));
      return;
    }

  if ((i & FORM3_MASK) == RESTORE_TEMPLATE || (i & FORM3_MASK) == SAVE_TEMPLATE
      || (i & FORM3_MASK) == RETT_TEMPLATE || (i & FORM3_MASK) == JMP_TEMPLATE)
    {
      printf ("RESTORE/SAVE, skipping ");
      __asm__ __volatile__ ("\
                    			 st %[value], %[result] \n\
                    			  "
	  : // No output
	  : [result]"m"(result),
	  [value]"r"(0x40000880));
      return;
    }

  if ((i & FORM3_MASK) == UDIV_TEMPLATE || (i & FORM3_MASK) == SDIV_TEMPLATE
        || (i & FORM3_MASK) == UDIVC_TEMPLATE || (i & FORM3_MASK) == SDIVC_TEMPLATE)
      {
        printf ("DIV instruction, skipping ");
        __asm__ __volatile__ ("\
                      			 st %[value], %[result] \n\
                      			  "
  	  : // No output
  	  : [result]"m"(result),
  	  [value]"r"(0x40000880));
        return;
      }

  if((i & FORM3_MASK) == TRAP_TEMPLATE){
      printf ("Trap instruction, skipping ");
              __asm__ __volatile__ ("\
                            			 st %[value], %[result] \n\
                            			  "
        	  : // No output
        	  : [result]"m"(result),
        	  [value]"r"(0x40000880));
              return;
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

  __asm__ __volatile__ ("\
			 mov %[i], %%i7 \n\
			  "
      : // No output
      : [i]"r"((&anchor_point - 2)));

}

void
handle_result (void)
{
  tbr_value = ((int) ((int*) result));
  tbr_from_lib = bcc_get_tbr ();

  if (last_trap < 0)
    {
      last_trap = tbr_value;
    }

  if (tbr_value == last_trap)
    {
      cont_traps++;
      if (cont_traps
	  >= 10 * search_range.rate&& search_range.direction == SEARCH_FORWARD)
	{
	  search_range.rate *= 10;
	  cont_traps = 0;
	}
    }
  else
    {
      search_range.rate = 1;
      last_trap = tbr_value;
      cont_traps = 0;

      if (search_range.direction == SEARCH_FORWARD)
	{
	  search_range.last_switch = search_range.true_value;
	  search_range.direction = SEARCH_BACK;
	  search_range.rate = 100;
	}
      else
	{
	  search_range.true_value = search_range.last_switch;
	  search_range.direction = SEARCH_FORWARD;
	  last_trap = -1;
	  search_range.rate = 1;
	}

    }

  if (trap_occured && tbr_value != 0x40000880)
    {
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
  initialize ();
  set_trap_handlers ();

  packet_buffer = malloc (INSN_SIZE * 10);
  cont_traps = 0;
  last_trap = -1;

  while (move_next_instruction ())
    {
      inject ();
      hexDump ("instruction:", packet, 4);
      handle_result ();
    }

  puts ("Search finished!");
  return (EXIT_SUCCESS);
}
