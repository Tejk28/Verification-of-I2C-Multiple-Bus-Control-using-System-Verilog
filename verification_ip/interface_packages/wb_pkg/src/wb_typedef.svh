typedef enum bit { bus_busy = 1'b1,
                   bus_not_busy = 1'b0

                 }bus_status_t;

typedef enum bit { bus_captured = 1'b1,
                   bus_not_captured = 1'b0
          
                 }bus_cap_status_t;

typedef enum bit { intr_en = 1'b1,
                   intr_not_en = 1'b0

                 }intr_enable_t;

typedef enum bit { al_en = 1'b1,
                   al_not_en = 1'b0
                
                 }al_enable_t;

typedef enum bit[7:0] {
                         enable = 8'b1100_0000,
                         set_bus= 8'b0000_0110,
                         start  = 8'b0000_0100,
                         stop   = 8'b0000_0101,
                         write  = 8'b0000_0001,
                         ack_read = 8'b0000_0010,
                         nack_read = 8'b0000_0011
                         
                      }register_inits_t;

typedef enum bit[3:0] { idle    = 4'b0000,
                        start_A = 4'b0001,
                        start_B = 4'b0010,
                        start_C = 4'b0011,
                        rw_A    = 4'b0100,
                        rw_B    = 4'b0101,
                        rw_C    = 4'b0110,
                        rw_D    = 4'b0111,
                        rw_E    = 4'b1000,
                        stop_A  = 4'b1001,
                        stop_B  = 4'b1010,
                        stop_C  = 4'b1011,
                        rstart_A= 4'b1100,
                        rstart_B= 4'b1101,
                        rstart_C= 4'b1110

                      }fsmr_bit_t;
