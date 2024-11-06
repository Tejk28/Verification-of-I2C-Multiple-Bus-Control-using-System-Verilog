`include "../../ncsu_pkg/ncsu_pkg.sv"
`include "../../parameter_pkg/parameter_pkg.sv"

package wb_pkg;

 import ncsu_pkg::*;
 import parameter_pkg::*;


 `include "../../ncsu_pkg/ncsu_macros.svh"
 `include "src/wb_typedef.svh"

 `include "src/wb_configuration.svh"
 `include "src/wb_transaction.svh"
 `include "src/wb_rand_transaction.svh"
 `include "src/wb_driver.svh"
 `include "src/wb_monitor.svh"
 `include "src/wb_coverage.svh"
 `include "src/wb_agent.svh"

endpackage
