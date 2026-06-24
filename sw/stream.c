typedef int int32_t;
typedef unsigned int uint32_t;

void process_telemetry_stream(int32_t* raw_data, uint32_t* net_buffer, uint32_t config_reg, int length) {
    
    // 1. MASKI (I-Type)
    // "i" constraint tells the compiler the '8' is an immediate value.
    uint32_t device_id;
    asm volatile ("maski %0, %1, %2" 
                  : "=r" (device_id) 
                  : "r" (config_reg), "i" (8));

    // 2. BSWAP (R-Type)
    uint32_t net_header;
    asm volatile ("bswap %0, %1" 
                  : "=r" (net_header) 
                  : "r" (device_id));

    net_buffer[0] = net_header;

    for (int i = 0; i < length; i++) {
        
        // 3. CABS (R-Type)
        uint32_t magnitude;
        asm volatile ("cabs %0, %1" 
                      : "=r" (magnitude) 
                      : "r" (raw_data[i]));

        // 4. BITREV (R-Type)
        uint32_t scrambled_payload;
        asm volatile ("bitrev %0, %1" 
                      : "=r" (scrambled_payload) 
                      : "r" (magnitude));

        // 5. SW.BSWAP (S-Type)
        // Memory instructions don't have a destination register, so the first list is empty.
        // We use "memory" in the clobber list so the compiler knows memory was altered.
        asm volatile ("sw.bswap %0, %2(%1)" 
                      : 
                      : "r" (scrambled_payload), "r" (&net_buffer[i + 1]), "i" (0)
                      : "memory");
    }
}