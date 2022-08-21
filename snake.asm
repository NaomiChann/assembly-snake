# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#			    			 Fernanda Petiz  -  Naomi Ribes								#
# # # #	+ + - -															  - - + + # # # #
#																						#
#				   ,#####   ,##     ,##    ,####    ,##   ,##  ,########				#
#				  ,##  ,##  ,####   ,##   ,######   ,##   ,##  ,##						#
#				  ,###      ,#####  ,##  ,##   ,##  ,## ,###   ,##						#
#				   ,###     ,##,### ,##  ,##   ,##  ,#####     ,#####					#
#				    ,###    ,## ,###,##  ,########  ,## ,###   ,##						#
#				     ,###   ,##  ,#####  ,##   ,##  ,##  ,###  ,##						#
#				 ,##  ,##   ,##   ,####  ,##   ,##  ,##   ,##  ,##						#
#				  ,#####    ,##    ,###  ,##   ,##  ,##   ,##  ,########				#
#																						#
# # # #	+ + - - 						   :)							  - - + + # # # #
#																						#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#																						#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = #
# 							   	   INSTRUCOES DE USO:									#
# # # # # # + + + + = = = - - -							  - - - = = = + + + + # # # # # #
#																						#
# Configuracoes para o bitmap display:													#
#																						#
# Unit Width in Pixels = 8																#
# Unit Height in Pixels = 8																#
# Display Width in Pixels = 512															#
# Display Height in Pixels = 256														#
# Base address for display = 0x10008000													#
#																						#
# Movimento: 																			#
# W = cima		A = esquerda		  S = baixo		    D = direita						#
#																						#
# Pressiona a tecla soh uma vez, se segurar o botao trava								#
#																						#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#																						#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#									  DEFINICOES										#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#									#					 					   enderecos
.data								#				 			(comecando em 0x1001000)
	eb_display:	.word 0x10008000 	# endereco base do display					0x..00
	# fisica da snake
	velX:		.word 0				# velocidade atual da snake em x			0x..04
	velY:		.word 0				# velocidade atual da snake em y			0x..08
	posX:		.word 19			# posicao x seguinte da snake				0x..0c
	posY:		.word 16			# posicao y seguinte da snake				0x..10
	rabo:		.word 4160			# posicao atual do rabo da snake (16, 16)	0x..14
	# o 1o byte identifica a direcao de movimento e os outros 3 o valor da cor em rgb
	snakeCima:	.word 0x00556b2f	# 0 = cima									0x..18
	snakeEsq:	.word 0x01556b2f	# 1 = esquerda								0x..1c
	snakeBaixo:	.word 0x02556b2f	# 2 = baixo									0x..20
	snakeDir:	.word 0x03556b2f	# 3 = direita								0x..24
	# como a fruta nao se move o byte de identificacao dela so indica que eh uma fruta
	frutaCor:	.word 0x04556b2f	# 4 = fruta									0x..28
	fundoCor:	.word 0x9acd32		# cor pro fundo								0x..2c
	# o display usa soh 2 cores por escolha artistica, nao eh uma necessidade
	#
	# mover em x = adicionar (direita) ou subtrair (esquerda) 4 da posicao atual
	# mover em y = adicionar (descer) ou subtrair (subir) 256 da posicao atual
	# conversor (x, y) pra valor no bitmap:
	# posicao no bitmap = (x * 4) + (y * 256)
	conversorX:	.word 4				# numero de conversao de x					0x..30
	conversorY:	.word 256			# numero de conversao de y					0x..34

.text
main:

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#									SETUP DO DISPLAY									#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

	lw $t0, eb_display				# $t0 = endereco da posicao (0, 0)
	lw $t1, fundoCor				# $t1 = verde claro
	li $t2, 2048					# contador; 2048px de area
	
fundo:
	sw $t1, 0($t0)					# troca o valor da posicao pra verde claro
	addi $t0, $t0, 4				# incrementa x em 1
	addi $t2, $t2, -1				# atualiza o contador
	bne $t2, $0, fundo				# loop ate o contador zerar
	# posicao atual: (0, 32)
	lw $t0, eb_display				# $t0 = endereco da posicao (0, 0)
	lw $t1, snakeCima				# $t1 = verde escuro
	li $t2, 64						# contador; 64px de largura
	bne $s0, $0, fim				# no retorno pula o resto da criacao
	li $s0, 1						# incrementa o contador pra quando retornar
	
parede_topo:
	sw $t1, 0($t0)					# troca o valor da posicao atual pra verde escuro
	addi $t0, $t0, 4				# incrementa x em 1
	addi $t2, $t2, -1				# atualiza o contador
	bne $t2, $0, parede_topo		# loop ate o contador zerar
	# posicao atual: (0, 1) ou (0, 32) no retorno
	beq $t0, 0x1000a000, cria_snake	# desvio se a posicao atual for (0, 32)
	li $t2, 30						# contador; 32px de altura - topo e base
	
parede_lado:
	sw $t1, 0($t0)					# troca o valor da posicao atual pra verde escuro
	addi $t0, $t0, 252				# $t0 vai pra extremidade direita (63, y)
	sw $t1, 0($t0)					# troca o valor da posicao atual pra verde escuro
	addi $t0, $t0, 4				# $t0 vai pra extremidade esquerda, desce 1 linha
	addi $t2, $t2, -1				# atualiza o contador
	bne $t2, $0, parede_lado		# loop ate o contador zerar
	# posicao atual: (0, 31)
	li $t2, 64						# contador; 64px de largura
	j parede_topo					# reutiliza a logica do topo pra criar a base
	
cria_snake:
	lw $t0, eb_display				# $t0 = endereco da posicao (0, 0)
	lw $s2, rabo					# $s2 = posicao do rabo (16, 16)
	lw $s3, snakeDir				# $s3 = direcao da snake (direita)
	li $t5, 3						# %t5 = failsafe pro movimento (3 = direita)
	add $t0, $t0, $s2				# $t0 vai pra posicao do rabo (16, 16)
	sw $s3, 0($t0)					# guarda na posicao atual o valor da cor e direcao
	addi $t0, $t0, 4				# avanca 1 posicao em x (17, 16)
	sw $s3, 0($t0)					# guarda na posicao atual o valor da cor e direcao
	addi $t0, $t0, 4				# avanca 1 posicao em x (18, 16)
	sw $s3, 0($t0)					# guarda na posicao atual o valor da cor e direcao
	lw $s1, frutaCor				# $s1 = fruta
	addi $t0, $t0, -488				# vai pra posicao (32, 16)
	sw $s1, 0($t0)					# guarda na posicao atual o valor da fruta
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#								  FIM DA SETUP DO DISPLAY								#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

	# registradores com funcao fixa:
	#
	# $t3 = posicao em frente
	# $t4 = valor da posicao em frente
	# $t5 = failsafe
	# $s2 = posicao do rabo em bitmap
	# $s3 = cabeca nova (com direcao e cor)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#				      				  LOOP PRINCIPAL									#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

loop:
	# setup
	lw $t3, 0xffff0004			# $t3 = endereco de input do teclado
	li $v0, 32					# chama sleep pra syscall
	li $a0, 50					# define tempo de sleep pra 50ms (20fps)
	syscall						#
	lw $s2, rabo				# $s3 = posicao do rabo

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#					  					INPUT											#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

	beq $t3, $0, direita			# move pra direita como padrao
	beq $t3, 0x77, cima				# move pra cima se a ultima tecla foi w
	beq $t3, 0x61, esquerda			# move pra esquerda se a ultima tecla foi a
	beq $t3, 0x73, baixo			# move pra baixo se a ultima tecla foi s
	beq $t3, 0x64, direita			# move pra direita se a ultima tecla foi d
	
cima:
	beq $t5, 2, baixo				# desvio pra baixo se a anterior foi baixo
	li $t5, 0						# atualiza o failsafe pra cima
	lw $s3, snakeCima				# $s3 = direcao cima
	jal atualiza_snake				# desvio pro loop de atualizar
	jal atualiza_cabeca				# desvio pro loop de movimentar
	j atualiza_rabo					# desvio pra 2a parte do loop de movimentar

esquerda:
	beq $t5, 3, direita				# desvio pra direita se a anterior foi direita
	li $t5, 1						# atualiza o failsafe pra esquerda
	lw $s3, snakeEsq				# $s3 = direcao esquerda
	jal atualiza_snake				# desvio pro loop de atualizar
	jal atualiza_cabeca				# desvio pro loop de movimentar
	j atualiza_rabo					# desvio pra 2a parte do loop de movimentar
	
baixo:
	beq $t5, 0, cima				# desvio pra cima se a anterior foi cima
	li $t5, 2						# atualiza o failsafe pra baixo
	lw $s3, snakeBaixo				# $s3 = direcao baixo
	jal atualiza_snake				# desvio pro loop de atualizar
	jal atualiza_cabeca				# desvio pro loop de movimentar
	j atualiza_rabo					# desvio pra 2a parte do loop de movimentar
	
direita:
	beq $t5, 1, esquerda			# desvio pra esquerda se a anterior foi esquerda
	li $t5, 3						# atualiza o failsafe pra direita
	lw $s3, snakeDir				# $s3 = direcao direita
	jal atualiza_snake				# desvio pro loop de atualizar
	jal atualiza_cabeca				# desvio pro loop de movimentar
	j atualiza_rabo					# desvio pra 2a parte do loop de movimentar
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#								 ATUALIZACAO DO DISPLAY									#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = #
#								 CONTROLE DE MOVIMENTO									#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = #
#								    	CABECA											#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

atualiza_snake:
	lw $t0, conversorX				# $t0 = valor de conversao pra x (4)
	lw $t1, posX					# $t1 = posicao de x seguinte
	mult $t1, $t0					# calcula x * 4
	mflo $t1						# $t1 = x convertido pro bitmap
	
	lw $t0, conversorY				# $t0 = valor de conversao pra y (256)
	lw $t2, posY					# $t2 = posicao de y seguinte
	mult $t2, $t0					# calcula y * 256
	mflo $t2						# $t2 = y convertido pro bitmap
	
	lw $t0, eb_display				# $t0 = (0, 0)
	add $t3, $t1, $t2				# $t3 = soma do valor de bitmap de x e y
	add $t3, $t0, $t3				# $t3 = endereco da posicao nova
	lw $t4, 0($t3)					# $t4 = valor na posicao seguinte

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#										DIRECAO											#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

	lw $t2, snakeDir				# $t2 = cor com byte de direcao 03 (direita)
	beq $s3, $t2, vel_dir			# desvio se a direcao atual for igual
		
	lw $t2, snakeEsq				# $t2 = cor com byte de direcao 01 (esquerda)
	beq $s3, $t2, vel_esq			# desvio se a direcao atual for igual
	
	lw $t2, snakeCima				# $t2 = cor com byte de direcao 00 (cima)
	beq $s3, $t2, vel_cima			# desvio se a direcao atual for igual
	
	lw $t2, snakeBaixo				# $t2 = cor com byte de direcao 02 (baixo)
	beq $s3, $t2, vel_baixo			# desvio se a direcao atual for igual

vel_cima:
	addi $t0, $0, 0					# $t0 = velocidade de x
	addi $t1, $0, -1				# $t1 = velocidade de y
	sw $t0, velX					# atualiza a velocidade de x
	sw $t1, velY					# atualiza a velocidade de y
	j checa_fruta					# desvio pro proximo passo
	
vel_esq:
	addi $t0, $0, -1				# $t0 = velocidade de x
	addi $t1, $0, 0					# $t1 = velocidade de y
	sw $t0, velX					# atualiza a velocidade de x
	sw $t1, velY					# atualiza a velocidade de y
	j checa_fruta					# desvio pro proximo passo

vel_baixo:
	addi $t0, $0, 0					# $t0 = velocidade de x
	addi $t1, $0, 1					# $t1 = velocidade de y
	sw $t0, velX					# atualiza a velocidade de x
	sw $t1, velY					# atualiza a velocidade de y
	j checa_fruta					# desvio pro proximo passo

vel_dir:
	addi $t0, $0, 1					# $t0 = velocidade de x
	addi $t1, $0, 0					# $t1 = velocidade de y
	sw $t0, velX					# atualiza a velocidade de x
	sw $t1, velY					# atualiza a velocidade de y
	j checa_fruta					# desvio pro proximo passo

checa_fruta:
	lw $t1, frutaCor				# $t1 = valor da fruta
	bne $t1, $t4, nao_fruta			# desvio se a posicao seguinte nao for fruta
	j unidade						# incrementa o contador de pontuacao em 1
	
nao_fruta:
	lw $t1, fundoCor				# $t1 = valor do fundo
	beq $t1, $t4, livre				# desvio se a posicao seguinte nao for colisao
	# morre :(
	lw $t0, eb_display				# $t0 = (0, 0)
	lw $t1, snakeCima				# $t1 = verde escuro
	li $t2, 2048					# contador; 2048px de area
	j fundo							# desvio pra limpar a tela
	
livre:
	sw $s3, 0($t3)					# cria uma cabeca na posicao seguinte
	jr $ra							# desvio de retorno pra a chamada original
									# (entre as linhas 162 e 194 por enquanto)
atualiza_cabeca:
	lw $t0, posX					# $t0 = valor de x
	lw $t1, velX					# $t1 = velocidade em x
	add $t0, $t0, $t1				# atualiza a posicao pro proximo loop
	sw $t0, posX					# guarda o valor novo de x
	
	lw $t0, posY					# $t0 = valor de y
	lw $t1, velY					# $t1 = velocidade em y
	add $t0, $t0, $t1				# atualiza a posicao pro proximo loop
	sw $t0, posY					# guarda o valor novo de y
	
	jr $ra							# desvio de retorno pra a chamada original
									# (entre as linhas 162 e 194 por enquanto)
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#					  					  RABO											#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

atualiza_rabo:
	lw $t0, eb_display				# $t0 = (0, 0)
	add $t0, $t0, $s2				# vai pra posicao do rabo 
	lw $t1, 0($t0)					# $t1 = valor da posicao
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#									    DIRECAO											#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

	lw $t2, snakeDir				# $t2 = cor com byte de direcao 03 (direita)
	beq $t1, $t2, rabo_dir			# desvio se a direcao atual for igual
		
	lw $t2, snakeEsq				# $t2 = cor com byte de direcao 01 (esquerda)
	beq $t1, $t2, rabo_esq			# desvio se a direcao atual for igual
	
	lw $t2, snakeCima				# $t2 = cor com byte de direcao 00 (cima)
	beq $t1, $t2, rabo_cima			# desvio se a direcao atual for igual
	
	lw $t2, snakeBaixo				# $t2 = cor com byte de direcao 02 (baixo)
	beq $t1, $t2, rabo_baixo		# desvio se a direcao atual for igual
	
rabo_dir:
	addi $s2, $s2, 4				# atualiza a posicao do rabo
	lw $t2, fundoCor				# $t2 = verde claro
	sw $t2, 0($t0)					# troca o rabo anterior por fundo
	sw $s2, rabo					# atualiza o valor do rabo no bitmap
	j loop							# reinicia o loop
	
rabo_esq:
	addi $s2, $s2, -4				# atualiza a posicao do rabo
	lw $t2, fundoCor				# $t2 = verde claro
	sw $t2, 0($t0)					# troca o rabo anterior por fundo
	sw $s2, rabo					# atualiza o valor do rabo no bitmap
	j loop							# reinicia o loop
	
rabo_cima:
	addi $s2, $s2, -256				# atualiza a posicao do rabo
	lw $t2, fundoCor				# $t2 = verde claro
	sw $t2, 0($t0)					# troca o rabo anterior por fundo
	sw $s2, rabo					# atualiza o valor do rabo no bitmap
	j loop							# reinicia o loop
	
rabo_baixo:
	addi $s2, $s2, 256				# atualiza a posicao do rabo
	lw $t2, fundoCor				# $t2 = verde claro
	sw $t2, 0($t0)					# troca o rabo anterior por fundo
	sw $s2, rabo					# atualiza o valor do rabo no bitmap
	j loop							# reinicia o loop
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#			     				FIM DO CONTROLE DE MOVIMENTO							#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#										  FRUTA											#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = #
#			      				 GERADOR DE NUMERO ALEATORIO							#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
	
rng:
	addi $v0, $0, 42				# chama um gerador de int aleatorio pra syscall
	addi $a1, $0, 64				# valor limite do numero entre 0 e 64 (largura)
	syscall							#
	add $t1, $0, $a0				# $t1 = numero gerado pra x
	
	addi $v0, $0, 42				# chama um gerador de int aleatorio pra syscall
	addi $a1, $0, 32				# valor limite do numero entre 0 e 32 (altura)
	syscall 						#
	add $t2, $0, $a0				# $t2 = numero gerado pra y
	
	lw $a1, conversorX				# $a1 = valor de conversao pra x (4)
	mult $t1, $a1					# calcula x * 4
	mflo $t1						# $t1 = x convertido pra bitmap
	
	lw $a1, conversorY				# $a1 = valor de conversao pra y (256)
	mult $t2, $a1					# calcula y * 256
	mflo $t2						# $t1 = y convertido pra bitmap
	add $a1, $t1, $t2 				# $a1 = posicao da fruta no bitmap
    
	lw $t0, eb_display				# $t0 = (0, 0)
	lw $t1, frutaCor				# $t1 = fruta
	lw $t2, fundoCor				# $t2 = verde claro
	add $t0, $t0, $a1				# atualiza pra posicao gerada da fruta
	lw $a1, 0($t0)					# $a1 = valor da posicao da fruta
	bne $a1, $t2, rng				# loopa se a posicao nao estiver livre
	sw $t1, 0($t0) 					# cria uma fruta na posicao gerada
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#			    	        			 COMER											#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

	sw $s3, 0($t3)					# troca o valor em frente por uma cabeca
	lw $t4, 0($t3)					# atualiza o valor em frente em $t4
	
	lw $t2, snakeDir				# $t2 = cor com byte de direcao 03 (direita)
	beq $t4, $t2, aumenta_dir		# desvio se a direcao atual for igual
		
	lw $t2, snakeEsq				# $t2 = cor com byte de direcao 01 (esquerda)
	beq $t4, $t2, aumenta_esq		# desvio se a direcao atual for igual
	
	lw $t2, snakeCima				# $t2 = cor com byte de direcao 00 (cima)
	beq $t4, $t2, aumenta_cima		# desvio se a direcao atual for igual
	
	lw $t2, snakeBaixo				# $t2 = cor com byte de direcao 02 (baixo)
	beq $t4, $t2, aumenta_baixo		# desvio se a direcao atual for igual
	
aumenta_cima:
	lw $t0, posY					# $t0 = y
	addi $t3, $t3, -256				# muda o endereco em frente 1 posicao em y
	sw $t4, 0($t3)					# atualiza o valor da posicao em frente
	addi $t0, $t0, -1				# atualiza y 1 posicao pra cima
	j atualiza_cabeca				# retorna pro movimento
	
aumenta_esq:
	lw $t0, posX					# $t0 = x
	addi $t3, $t3, -4				# muda o endereco em frente 1 posicao em x
	sw $t4, 0($t3)					# atualiza o valor da posicao em frente
	addi $t0, $t0, -1				# atualiza x 1 posicao pra esquerda
	j atualiza_cabeca				# retorna pro movimento
	
aumenta_baixo:
	lw $t0, posY					# $t0 = y
	addi $t3, $t3, 256				# muda o endereco em frente 1 posicao em y
	sw $t4, 0($t3)					# atualiza o valor da posicao em frente
	addi $t0, $t0, 1				# atualiza y 1 posicao pra baixo
	j atualiza_cabeca				# retorna pro movimento
	
aumenta_dir:
	lw $t0, posX					# $t0 = x
	addi $t3, $t3, 4				# muda o endereco em frente 1 posicao em x
	sw $t4, 0($t3)					# atualiza o valor da posicao em frente
	addi $t0, $t0, 1				# atualiza x 1 posicao pra direita
	j atualiza_cabeca				# retorna pro movimento
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#				   					CONTADOR INDIVIDUAL									#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = #
#																						#
# igual um contador noemal mas guarda cada numero individualmente em um registrador		#
# proprio; se a posicao atual tem mais de 1 digito pula pra seguinte, zera a anterior	#
# e vai pro primeiro passo de gerar uma fruta nova (ja que incrementa quando come)		#
# como milhar nao tem seguinte e a pontuacao maxima eh 2113 nao precisa milhao			#
#																						#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

unidade:
	addi $s4, $s4, 1				# adiciona 1 ao contador de unidade
	beq $s4, 10, dezena				# se ele passou de um digito unico vai pra dezena
	j rng							# caso contrario comeca a gerar uma fruta nova
dezena:
	li $s4, 0						# zera o contador de unidade
	addi $s5, $s5, 1				# adiciona 1 ao contador de dezena
	beq $s5, 10, centena			# se ele passou de um digito unico vai pra centena
	j rng							# caso contrario comeca a gerar uma fruta nova
centena:
	li $s5, 0						# zera o contador de dezena
	addi $s6, $s6, 1				# adiciona 1 ao contador de centena
	beq $s6, 10, milhar				# se ele passou de um digito unico vai pra milhar
	j rng							# caso contrario comeca a gerar uma fruta nova
milhar:
	li $s6, 0						# zera o contador de centena
	addi $s7, $s7, 1				# adiciona 1 ao contador de milhar
	j rng							# caso contrario comeca a gerar uma fruta nova

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#					  					  PLACAR										#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
	
	# registradores com funcao fixa:
	# 
	# $s4 = unidade					# $s5 = dezena
	# $s6 = centena					# $s7 = milhar
	# $s8 = contador de posicao

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#																						#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

fim:
	lw $t0, eb_display				# $t0 = (0, 0)
	addi $t0, $t0, 260				# vai pra (1, 1)
	beq $s0, 1, mil					# desvio pra printar o 1o mais significativo
	beq $s0, 2, cen					# desvio pra printar o 2o mais significativo
	beq $s0, 3, dez					# desvio pra printar o 3o mais significativo
	beq $s0, 4, uni					# desvio pra printar o 4o mais significativo
	beq $s0, 5, termina				# se printou a unidade sai do loop
mil:
	lw $t2, fundoCor				# $t2 = verde claro
	add $t1, $0, $s7				# $t1 = valor do milhar
	jal checador					# desvio pra descobrir o numero
cen:
	addi $t0, $t0, 20				# vai pra posicao ao lado do numero anterior
	add $t1, $0, $s6				# $t1 = valor da centena
	jal checador					# desvio pra descobrir o numero
dez:
	addi $t0, $t0, 40				# vai pra posicao ao lado do numero anterior
	add $t1, $0, $s5				# $t1 = valor da dezena
	jal checador					# desvio pra descobrir o numero
uni:
	addi $t0, $t0, 60				# vai pra posicao ao lado do numero anterior
	add $t1, $0, $s4				# $t1 = valor da unidade
	jal checador					# desvio pra descobrir o numero

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#										 TRADUTOR										#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = #
#																						#
# inspirado no metodo usado pra display de led mas so descobri que realmente eh feito	#
# assim depois de pensar na ideia entao a organizacao do meu tradutor eh diferente		#
# 																						#
#	traducao de numero pro codigo;														#
#																						# 
#	# 1 = 0x0010010 # 2 = 0x1011101 #													#
#	# 3 = 0x1011011 # 4 = 0x0111010 #													#
#	# 5 = 0x1101011 # 6 = 0x1101111 #													#
#	# 7 = 0x1010010 # 8 = 0x1111111 #													#
#	# 9 = 0x1111011 # 0 = 0x1110111 #													#
#																						#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

checador:
	beq $t1, 1, um					# provavelmente
	beq $t1, 2, dois				# tem
	beq $t1, 3, tres				# uma
	beq $t1, 4, quatro				# maneira
	beq $t1, 5, cinco				# mais
	beq $t1, 6, seis				# bonita
	beq $t1, 7, sete				# de
	beq $t1, 8, oito				# fazer
	beq $t1, 9, nove				# isso
	beq $t1, 0, zero				# aqui
	# mas eu nao sei
	
zero:
	la $t3, 0x01110111				# $t3 = valor de 0 no codigo pro display
	j pri							# desvio pra traducao de codigo pra tela
	
um:
	la $t3, 0x00010010				# $t3 = valor de 1 no codigo pro display
	j pri							# desvio pra traducao de codigo pra tela
	
dois:
	la $t3, 0x01011101				# $t3 = valor de 2 no codigo pro display
	j pri							# desvio pra traducao de codigo pra tela
	
tres:
	la $t3, 0x01011011				# $t3 = valor de 3 no codigo pro display
	j pri							# desvio pra traducao de codigo pra tela
	
quatro:
	la $t3, 0x00111010				# $t3 = valor de 4 no codigo pro display
	j pri							# desvio pra traducao de codigo pra tela
	
cinco:
	la $t3, 0x01101011				# $t3 = valor de 5 no codigo pro display
	j pri							# desvio pra traducao de codigo pra tela
	
seis:
	la $t3, 0x01101111				# $t3 = valor de 6 no codigo pro display
	j pri							# desvio pra traducao de codigo pra tela
	
sete:
	la $t3, 0x01010010				# $t3 = valor de 7 no codigo pro display
	j pri							# desvio pra traducao de codigo pra tela
	
oito:
	la $t3, 0x01111111				# $t3 = valor de 8 no codigo pro display
	j pri							# desvio pra traducao de codigo pra tela
	
nove:
	la $t3, 0x01111011				# $t3 = valor de 9 no codigo pro display
	j pri							# desvio pra traducao de codigo pra tela
	
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#										DISPLAYER										#
# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = #
#																						#
# quando se faz um and com f o que resta eh o proprio numero porque f = 11 entao tudo	#
# que ele tiver em comum repete; sendo assim, se um numero maior que f for usado no and	#
# somente os que colidem vao permanecer													#
#																						#
#		0x1234			0 0 0 1   0 0 1 0   0 0 1 1   0 1 0 0							#
# and	0x00ff			0 0 0 0   0 0 0 0   1 1 1 1   1 1 1 1							#
#		= = = =			= = = = = = = = = = = = = = = = = = =							#
#		0x0034			0 0 0 0   0 0 0 0   0 0 1 1   0 1 0 0							#
#																						#
# pra conseguir isolar um numero no meio do valor seria necessario tirar todo o resto	#
# do caminho, entao se faz um shift right de 4bit pra cada numero no caminho			#
#																						#
# sr 4	0x1234			0 0 0 1   0 0 1 0   0 0 1 1   0 1 0 0							#
#		= = = =			= = = = = = = = = = = = = = = = = = =							#
#		0x0123			0 0 0 0   0 0 0 1   0 0 1 0   0 0 1 1							#
#																						#
# e depois faz o and com f																#
#																						#
#		0x0123			0 0 0 0   0 0 0 1   0 0 1 0   0 0 1 1							#
# and	0x00ff			0 0 0 0   0 0 0 0   1 1 1 1   1 1 1 1							#
#		= = = =			= = = = = = = = = = = = = = = = = = =							#
#		0x0023			0 0 0 0   0 0 0 0   0 0 1 0   0 0 1 1							#
#																						#
# como interessa 1 numero por vez, depois do shift necessario um and com 0xf eh usado	#
# e se o interesse for o mais significativo o shift eh suficiente						#
#																						#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
	
pri:
	la $t1, 0($t3)					# transfere o codigo pra $t1
	srl $t1, $t1, 24				# shift right de 24bit pra usar soh o 1o digito
	bne $t1, 1, seg					# se os 4bit que sobram forem 0x0 vai pro proximo
	jal linha						# desvio pra printar uma linha
	
seg:
	la $t1, 0($t3)					# transfere o codigo pra $t1
	srl $t1, $t1, 20				# shift right de 20bit pra usar soh o 2o digito
	andi $t1, $t1, 0xf				# and com 0xf pra remover o resto
	bne $t1, 1, ter					# se os 4bit que sobram forem 0x0 vai pro proximo
	jal single						# desvio pra printar uma coluna
	
ter:
	la $t1, 0($t3)					# transfere o codigo pra $t1
	addi $t0, $t0, 12				# vai pra direita
	srl $t1, $t1, 16				# shift right de 16bit pra usar soh o 3o digito
	andi $t1, $t1, 0xf				# and com 0xf pra remover o resto
	bne $t1, 1, qua					# se os 4bit que sobram forem 0x0 vai pro proximo
	jal single						# desvio pra printar uma coluna
	
qua:
	la $t1, 0($t3)					# transfere o codigo pra $t1
	addi $t0, $t0, 756				# volta pra esquerda e desce 1 coluna
	srl $t1, $t1, 12				# shift right de 12bit pra usar soh o 4o digito
	andi $t1, $t1, 0xf				# and com 0xf pra remover o resto
	bne $t1, 1, qui					# se os 4bit que sobram forem 0x0 vai pro proximo
	jal linha						# desvio pra printar uma coluna
	
qui:
	la $t1, 0($t3)					# transfere o codigo pra $t1
	srl $t1, $t1, 8					# shift right de 8bit pra usar soh o 5o digito
	andi $t1, $t1, 0xf				# and com 0xf pra remover o resto
	bne $t1, 1, sex					# se os 4bit que sobram forem 0x0 vai pro proximo
	jal single						# desvio pra printar uma coluna
	
sex:
	la $t1, 0($t3)					# transfere o codigo pra $t1
	addi $t0, $t0, 12				# vai pra direita
	srl $t1, $t1, 4					# shift right de 4bit pra usar soh o 6o digito
	andi $t1, $t1, 0xf				# and com 0xf pra remover o resto
	bne $t1, 1, set					# se os 4bit que sobram forem 0x0 vai pro proximo
	jal single						# desvio pra printar uma coluna
	
set:
	la $t1, 0($t3)					# transfere o codigo pra $t1
	addi $t0, $t0, 756				# volta pra esquerda e desce 1 coluna
	andi $t1, $t1, 0xf				# and com 0xf pra remover o resto e usar o 7o digito
	addi $s0, $s0, 1				# incrementa o contador de posicao
	bne $t1, 1, fim					# se os 4bit que sobram forem 0x0 avanca a posicao
	jal linha						# desvio pra printar uma linha
	j fim							# retorna pro fim depois de printar o ultimo segmento
	
linha:
	sw $t2, 0($t0)					# printa na posicao atual
	addi $t0, $t0, 4				# avanca x em 1 posicao
	sw $t2, 0($t0)					# printa na posicao atual
	addi $t0, $t0, 4				# avanca x em 1 posicao
	sw $t2, 0($t0)					# printa na posicao atual
	addi $t0, $t0, 4				# avanca x em 1 posicao
	sw $t2, 0($t0)					# printa na posicao atual
	addi $t0, $t0, -12				# retorna pra onde comecou
	jr $ra							# volta pra onde chamou
	
single:
	sw $t2, 0($t0)					# printa na posicao atual
	addi $t0, $t0, 256				# avanca y em 1 posicao
	sw $t2, 0($t0)					# printa na posicao atual
	addi $t0, $t0, 256				# avanca y em 1 posicao
	sw $t2, 0($t0)					# printa na posicao atual
	addi $t0, $t0, 256				# avanca y em 1 posicao
	sw $t2, 0($t0)					# printa na posicao atual
	addi $t0, $t0, -768				# retorna pra onde comecou
	jr $ra							# volta pra onde chamou
	
termina:
	li $v0, 10						# syscall for the fans
	syscall							# syscall for the fans
	# acabou :)
