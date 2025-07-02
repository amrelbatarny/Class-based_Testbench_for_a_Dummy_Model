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
		data.size() == n;
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
endclass : packet