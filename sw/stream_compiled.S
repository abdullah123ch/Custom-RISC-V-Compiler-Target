	.attribute	4, 16
	.attribute	5, "rv32i2p1"
	.file	"stream.c"
	.text
	.globl	process_telemetry_stream        # -- Begin function process_telemetry_stream
	.p2align	2
	.type	process_telemetry_stream,@function
process_telemetry_stream:               # @process_telemetry_stream
# %bb.0:                                # %entry
	#APP
	maski	a2, a2, 8
	#NO_APP
	#APP
	bswap	a2, a2
	#NO_APP
	sw	a2, 0(a1)
	blez	a3, .LBB0_3
# %bb.1:                                # %for.body.preheader
	addi	a1, a1, 4
	slli	a2, a3, 2
	add	a2, a0, a2
.LBB0_2:                                # %for.body
                                        # =>This Inner Loop Header: Depth=1
	lw	a3, 0(a0)
	#APP
	cabs	a3, a3
	#NO_APP
	#APP
	bitrev	a3, a3
	#NO_APP
	#APP
	sw.bswap	a3, 0(a1)
	#NO_APP
	addi	a0, a0, 4
	addi	a1, a1, 4
	bne	a0, a2, .LBB0_2
.LBB0_3:                                # %for.cond.cleanup
	ret
.Lfunc_end0:
	.size	process_telemetry_stream, .Lfunc_end0-process_telemetry_stream
                                        # -- End function
	.ident	"clang version 23.0.0git (https://github.com/llvm/llvm-project.git eb427a4cbbedcafd620780b74466f1e31b79a955)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
