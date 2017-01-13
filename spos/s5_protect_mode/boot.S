.code16
.section .text

# ������ FAT12 ���̵�ͷ
jmp		boot_entry
nop

#################################            FAT12            ################################
# FAT BPB�ṹ
BS_OEMName: 	.ascii		"ForrestY"		# OEM String, ���� 8 ���ֽ�
BPB_BytsPerSec:	.word		512				# ÿ�����ֽ���
BPB_SecPerClus:	.byte		1				# ÿ�ض�������
BPB_RsvdSecCnt:	.word		1				# Boot ��¼ռ�ö�������
BPB_NumFATs:	.byte		2				# ���ж��� FAT ��
BPB_RootEntCnt:	.word		224				# ��Ŀ¼�ļ������ֵ
BPB_TotSec16:	.word		2880			# �߼���������
BPB_Media:		.byte		0xF0			# ý��������
BPB_FATSz16:	.word		9				# ÿFAT������
BPB_SecPerTrk:	.word		18				# ÿ�ŵ�������
BPB_NumHeads:	.word		2				# ��ͷ��(����)
BPB_HiddSec:	.long		0				# ����������
BPB_TotSec32:	.long		0				# ��� wTotalSectorCount �� 0 �����ֵ��¼������
BS_DrvNum:		.byte		0				# �ж� 13 ����������
BS_Reserved1:	.byte		0				# δʹ��
BS_BootSig:		.byte		0x29			# ��չ������� (29h)
BS_VolID:		.long		0				# �����к�
BS_VolLab:		.ascii		"Tinix0.01  "	# ����, ���� 11 ���ֽ�
BS_FileSysType:	.ascii		"FAT12   "		# �ļ�ϵͳ����, ���� 8���ֽ�
##############################################################################################

# boot���
# ע: ���з��Ŷ����ӵ�0x7c00, ��boot.lds
boot_entry:

# ��ȡ������0x0820:0�ڴ�
# ���̽ṹ 80���ŵ���x18��������x512 bytes(�����Ĵ�С)x2��˫�棩 = 1440 x1024 bytes = 1440 KB = 1.44MB
# ch: �ŵ���, ��Ҫ����CYLS���ŵ�
# dh: ��ͷ��, 1.44M����˫��  
# cl: ������, 1.44M����һ���ŵ�18������
.equ CYLS, 10 								# �����ڴ�Ĵŵ���
		movw	$0, %ax						# ��ʼ��
		movw	%ax, %ds
		movw	%ax, %ss
		movw	%ax, %es
		movw	$0x8200, %sp

		#�����������̶���0x8000�ڴ洦
		movw	$0x0820, %ax				# 0x8200������������			
		movw	%ax, %es
		movb	$0, %ch						# �ŵ���
		movb	$0, %dh						# ��ͷ��
		movb	$2, %cl 					# ������, ��2��ʼ��������������
read_a_section:
		movw	$0, %si						# ʧ�ܴ���
retry:
		movb	$0x02, %ah					# int 0x13, ah = 0x02 ��ȡ��������
		movb	$1, %al						# ������
		movw	$0, %bx						# es:bx ���ݻ�������ַ
		movb	$0x00, %dl					# dh/dl ��ͷ��/��������(0x00,0x01Ϊ����,0x80,0x81ΪӲ��)
		int		$0x13
		jnc		next_section				
		addw	$1, %si 					# ��ȡʧ��
		cmp		$5, %si
		jae		inf_loop
		movb	$0x00, %ah					# int 0x13, ah = 0x00 ���̸�λ
		movb	$0x00, %dl
		int		$0x13
		jmp		retry
next_section:
		movw	%es, %ax					# ����������һ��������С(0x200, 512B)
		addw	$0x0020, %ax
		movw	%ax, %es					
		addb	$1, %cl 					# ��һ������
		cmp		$18, %cl 					# cl <= 18, 1.44M����һ���ŵ�ֻ��18������
		jbe		read_a_section				
		movb	$1, %cl 					# ����������1������
		addb	$1, %dh 					# ��һ������
		cmp		$2, %dh						# dh < 2, 1.44M������˫��
		jb		read_a_section				
		movb	$0, %dh						# ���ô�ͷ��0�Ŵ�ͷ
		addb	$1, %ch						# ��һ���ŵ�
		cmp		$CYLS, %ch					# ��Ҫ��ȡ�Ĵŵ���
		jb		read_a_section				# ch < CYLS,
		ljmp	$0,$0xc200					# ����loaderִ��(loader����������0x4200��, 0xc200=0x4200+0x8000)

inf_loop:
		jmp inf_loop	
					
		.org	510				# ����ֽ�
		.word	0xaa55			# ��������ֽ�55AA��AT&T����ļ������newline
		.org	0x168000		# 1.44M ����