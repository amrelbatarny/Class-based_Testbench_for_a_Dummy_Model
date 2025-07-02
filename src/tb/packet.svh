class packet;
	rand int n;			// Packet Size
	rand byte data[];	// Payload Data
	rand byte id;		// Packet ID
	
	constraint c {
		n inside {[10:100]};
		data.size() == n;
		unique {id};
	}
endclass : packet