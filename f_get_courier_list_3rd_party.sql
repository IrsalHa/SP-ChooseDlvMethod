CREATE OR REPLACE FUNCTION public.f_get_courier_list_3rd_party(
    in_akum_volume numeric,
    in_delivery_type text,
    in_delivery_sites text[]
)
RETURNS TABLE(
    courier_name text,
    service_name text,
    courier_code text,
    service_code text,
    weight numeric,
    with_insurance boolean,
    wood_packaging boolean,
    insurance_rate numeric,
    volume_divider numeric,
    additional_packaging_length numeric,
    additional_packaging_width numeric,
    additional_packaging_height numeric,
    api_service_id text,
    api_service_name text,
    endpoint_url text
)
LANGUAGE plpgsql
AS $$
BEGIN
    /*
        Create On  : 2026-02-19
        Create By  : Al
        Update Log :
            (date ; by ; description)
            - 2026-04-16 ; Al ; refactor query based on dfd logic
            - 2026-06-10 ; Al ; add new return column courier name and service name
            - 2026-06-26 ; Irsal ; add api_service_name return column
        Table used :
            - pgWarehouse.m_courier_3rd_party mc3p
            - pgWarehouse.s_courier_3rd_party sc3p
            - pgWarehouse.s_courier_3rd_party_detail_delivery_site scpdds
            - pgWarehouse.m_api_service mas
            - pgWarehouse.m_api_service_endpoint mase
            - pgHMSGeneral.ft_s_hms_detail_platform hdp
            - pgHMSGeneral.ft_s_hms_platform hp
    */

    RETURN QUERY
    SELECT
        mc3p.courier_name::TEXT,
        mc3p.service_name::TEXT,
        mc3p.courier_code::TEXT,
        mc3p.service_code::TEXT,
        (in_akum_volume / NULLIF(sc3p.volume_divider, 0))::DECIMAL(18, 2) AS weight,
        sc3p.with_insurance::BOOLEAN,
        sc3p.wood_packaging::BOOLEAN,
        sc3p.insurance_rate::DECIMAL(18, 2),
        sc3p.volume_divider::DECIMAL(18, 2),
        sc3p.additional_packaging_length::DECIMAL(18, 2),
        sc3p.additional_packaging_width::DECIMAL(18, 2),
        sc3p.additional_packaging_height::DECIMAL(18, 2),
        mas.api_service_id::TEXT,
        mas.api_service_name::TEXT,
        mase.endpoint_url::TEXT
    FROM m_courier_3rd_party mc3p
    JOIN s_courier_3rd_party sc3p ON mc3p.company_group = sc3p.company_group AND mc3p.courier_id = sc3p.courier_id AND sc3p.status = TRUE
    JOIN s_courier_3rd_party_detail_delivery_site scpdds ON sc3p.courier_id = scpdds.courier_id AND scpdds.delivery_site = ANY(in_delivery_sites)
    JOIN ft_s_hms_detail_platform hdp ON scpdds.platform_code = hdp.platform_code AND hdp.site_id = ANY(in_delivery_sites) AND hdp.status = TRUE
    JOIN ft_s_hms_platform hp ON hdp.platform_code = hp.platform_code AND hp.company_group = 'HSE' AND hp.status = TRUE AND hp.platform_type = 'ONLINE'
    JOIN m_api_service mas ON mc3p.api_service_id = mas.api_service_id
    JOIN m_api_service_endpoint mase ON mase.api_service_id = mas.api_service_id AND mase.endpoint_id = '1'
    WHERE mc3p.company_group = 'HSE'
      AND mc3p.delivery_type = in_delivery_type
      AND mc3p.status = TRUE
      AND (in_akum_volume / NULLIF(sc3p.volume_divider, 0)) BETWEEN sc3p.min_weight AND sc3p.max_weight;
END;
$$;
