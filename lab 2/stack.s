	        .text
			.global _start

_start:	

		MOV R0, #1
		MOV R1, #2
		MOV R2, #3

		//PUSH {R0}
		//PUSH {R1}
		//PUSH {R2}

		//POP {R0 - R2}

		SUB SP, SP, #12
		STR R0, [SP, #8]
		STR R1, [SP, #4]
		STR R2, [SP]

		ADD SP, SP, #12
		LDR R0, [SP, #-12]
		LDR R1, [SP, #-8]
		LDR R2, [SP, #-4]
		
