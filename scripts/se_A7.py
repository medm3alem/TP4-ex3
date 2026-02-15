#!/usr/bin/env python3
import argparse
import m5
from m5.objects import *

class L1ICache(Cache):
    size = "4kB"
    assoc = 1
    tag_latency = 2
    data_latency = 2
    response_latency = 2
    mshrs = 4
    tgts_per_mshr = 8

class L1DCache(Cache):
    size = "4kB"
    assoc = 1
    tag_latency = 2
    data_latency = 2
    response_latency = 2
    mshrs = 8
    tgts_per_mshr = 8

class L2Cache(Cache):
    size = "32kB"
    assoc = 1
    tag_latency = 20
    data_latency = 20
    response_latency = 20
    mshrs = 16
    tgts_per_mshr = 16

parser = argparse.ArgumentParser()
parser.add_argument("--cmd", required=True)
parser.add_argument("--cacheconfig", default="C1")
parser.add_argument("--maxinsts", type=int, default=0)
args = parser.parse_args()

system = System()
system.clk_domain = SrcClockDomain(clock="2GHz", voltage_domain=VoltageDomain())
system.mem_mode = "timing"
system.mem_ranges = [AddrRange("2GB")]
system.cache_line_size = 32

system.cpu = DerivO3CPU()
system.cpu.fetchBufferSize = 32
system.cpu.icache = L1ICache()
system.cpu.dcache = L1DCache()
system.l2cache = L2Cache()

if args.cacheconfig == "C2":
    system.cpu.dcache.assoc = 2
    system.l2cache.assoc = 4

system.l2bus = L2XBar()
system.membus = SystemXBar()

system.cpu.icache.cpu_side = system.cpu.icache_port
system.cpu.dcache.cpu_side = system.cpu.dcache_port
system.cpu.icache.mem_side = system.l2bus.cpu_side_ports
system.cpu.dcache.mem_side = system.l2bus.cpu_side_ports
system.l2cache.cpu_side = system.l2bus.mem_side_ports
system.l2cache.mem_side = system.membus.cpu_side_ports
system.system_port = system.membus.cpu_side_ports

system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR3_1600_8x8()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.mem_side_ports

process = Process()
process.cmd = [args.cmd]
system.cpu.workload = process
system.workload = SEWorkload.init_compatible(args.cmd)
system.cpu.createThreads()
system.cpu.createInterruptController()

root = Root(full_system=False, system=system)
m5.instantiate()
if args.maxinsts > 0:
    m5.simulate(args.maxinsts)
else:
    m5.simulate()
m5.stats.dump()
