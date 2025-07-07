/***********************************************************************
 * Author : Amr El Batarny
 * File   : packet.svh
 * Brief  : Packet transaction definition with size, ID and payload.
 ***********************************************************************/

class packet;
	rand int n;			// Packet Size
	rand byte data[];	// Payload Data
	rand byte id;		// Packet ID
	
	constraint c {
		n inside {[10:100]};
		soft data.size() == n;
		unique {id};
	}

	function void copy(packet rhs);
		// copy simple fields
		this.n  = rhs.n;
		this.id = rhs.id;
		
		// deep-copy dynamic array
		if (rhs.data.size() > 0) begin
		  this.data = new[rhs.data.size()];
		  foreach (rhs.data[i]) this.data[i] = rhs.data[i];
		end else begin
		  // no payload
		  this.data = {};
		end
 	endfunction : copy

 	function void compare(input packet rhs, inout report_object rep);
		if (this.data != rhs.data) begin
			$error("[%0t] MISMATCH ID=%0d exp.len=%0d act.len=%0d",
				$time, this.id, this.n, rhs.n);
			rep.mismatch_count++;
		end else begin
		  // $display("[%0t] MATCH    ID=%0d len=%0d", $time, this.id, this.n);
		  rep.match_count++;
		end
 	endfunction : compare
endclass : packet