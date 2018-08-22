################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../injector_sparc.c 

OBJS += \
./injector_sparc.o 

C_DEPS += \
./injector_sparc.d 


# Each subdirectory must supply rules for building sources it contributes
injector_sparc.o: ../injector_sparc.c
	@echo 'Building file: $<'
	@echo 'Invoking: Cross GCC Compiler'
	sparc-gaisler-elf-gcc -DSTART0=0x03 -DSTART1=0xff -DSTART2=0x00 -DSTART3=0xff -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"injector_sparc.d" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


