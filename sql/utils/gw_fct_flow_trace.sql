CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_flow_trace(node_id_arg character varying) RETURNS int2 AS $BODY$
DECLARE
 
BEGIN

    -- Compute the tributary area using DFS
    PERFORM "SCHEMA_NAME".gw_fct_flow_trace_recursive(node_id_arg);

    RETURN 0;
        
END;
$BODY$
  LANGUAGE plpgsql VOLATILE COST 100;



CREATE OR REPLACE FUNCTION "SCHEMA_NAME".gw_fct_flow_trace_recursive(node_id_arg character varying) RETURNS void AS $BODY$
DECLARE
    exists_id character varying;
    rec_table record;

BEGIN

    -- Check if the node is already computed
    SELECT node_id INTO exists_id FROM "SCHEMA_NAME".temp_flow_trace_node WHERE node_id = node_id_arg;

    -- Compute proceed
    IF NOT FOUND THEN
    
        -- Update value
        INSERT INTO "SCHEMA_NAME".temp_flow_trace_node VALUES(node_id_arg);
        
        -- Loop for all the upstream nodes
        FOR rec_table IN SELECT arc_id, node_1 FROM "SCHEMA_NAME".arc WHERE node_2 = node_id_arg
        LOOP

            -- Insert into tables
            INSERT INTO "SCHEMA_NAME".temp_flow_trace_arc VALUES(rec_table.arc_id);

            -- Call recursive function weighting with the pipe capacity
            PERFORM "SCHEMA_NAME".gw_fct_flow_trace_recursive(rec_table.node_1);

        END LOOP;
    
    END IF;

    RETURN;
        
END;
$BODY$
  LANGUAGE plpgsql VOLATILE COST 100;

