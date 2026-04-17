CREATE OR REPLACE FUNCTION f_get_price_packing_kayu(
    in_courier_id VARCHAR(20),
    in_weight_packaging NUMERIC,
    in_delivery_site VARCHAR(4)
)
RETURNS NUMERIC AS $$
DECLARE
    v_price NUMERIC;
BEGIN
    SELECT 
        swpdt.price INTO v_price
    FROM 
        m_courier_3rd_party mcp
    JOIN 
        s_wood_packaging swp 
        ON mcp.company_group = swp.company_group 
        AND mcp.courier_id = swp.courier_id 
        AND swp.status = true
    JOIN 
        s_wood_packaging_detail_delivery_site swpdds 
        ON swp.setup_id = swpdds.setup_id 
        AND swpdds.delivery_site = in_delivery_site 
        AND swpdds.status = true
    JOIN 
        s_wood_packaging_detail_tiering swpdt 
        ON swp.setup_id = swpdt.setup_id
        AND swpdt.status = true 
        AND in_weight_packaging BETWEEN swpdt.min_weight AND swpdt.max_weight
    WHERE 
        mcp.company_group = 'HSE'
        AND mcp.courier_id = in_courier_id
        AND mcp.status = true
    LIMIT 1;

  
    RETURN COALESCE(v_price, 0); 
END;
$$ LANGUAGE plpgsql;
