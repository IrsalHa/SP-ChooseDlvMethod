create function f_get_courier_list_3rd_party(in_akum_volume numeric, in_delivery_type character varying, in_delivery_sites character varying[])
    returns TABLE(courier_name character varying, service_name character varying, courier_code character varying, service_code character varying, weight numeric, with_insurance boolean, wood_packaging boolean, insurance_rate numeric, volume_divider numeric, additional_packaging_length numeric, additional_packaging_width numeric, additional_packaging_height numeric, api_service_id character varying, endpoint_url character varying)
    language plpgsql
as
$$
BEGIN
    RETURN QUERY
    SELECT
        mcp.courier_name,
        mcp.service_name,
        mcp.courier_code,
        mcp.service_code,
        (in_akum_volume / NULLIF(scp.volume_divider, 0)) AS weight,
        scp.with_insurance,
        scp.wood_packaging,
        scp.insurance_rate,
        scp.volume_divider,
        scp.additional_packaging_length,
        scp.additional_packaging_width,
        scp.additional_packaging_height,
        mas.api_service_id,
        mase.endpoint_url
    FROM
        m_courier_3rd_party mcp
    JOIN
        s_courier_3rd_party scp
        ON mcp.company_group = scp.company_group
        AND mcp.courier_id = scp.courier_id
        AND scp.status = true
    JOIN
        s_courier_3rd_party_detail_delivery_site scpdds
        ON scp.courier_id = scpdds.courier_id
        --AND scpdds.platform_code = 'ONLINE'
        AND scpdds.delivery_site =ANY (in_delivery_sites)
    JOIN
        ft_s_hms_detail_platform shds
        ON scpdds.platform_code = shds.platform_code
        AND shds.site_id = ANY (in_delivery_sites)
        AND shds.status = true
    JOIN
        ft_s_hms_platform shp
        ON shds.platform_code = shp.platform_code
        AND shp.company_group = 'HSE'
        AND shp.status = true
        AND shp.platform_type = 'ONLINE'
    JOIN
        m_api_service mas
        ON mcp.api_service_id = mas.api_service_id
    JOIN
        m_api_service_endpoint mase
        ON mas.api_service_id = mase.api_service_id
        AND mase.endpoint_id = 'CHECK_RATE'
    WHERE
        mcp.company_group = 'HSE'
        AND mcp.delivery_type = in_delivery_type
        AND mcp.status = true
        AND (in_akum_volume / NULLIF(scp.volume_divider, 0)) BETWEEN scp.min_weight AND scp.max_weight;
END;
$$;

alter function f_get_courier_list_3rd_party(numeric, varchar, character varying[]) owner to sysapp;

