CREATE OR REPLACE VIEW public.shipping_datamart AS 
SELECT si.shippingid,
	   si.vendorid,
	   st.transfer_type,
	   DATE_PART('day',AGE(ss.shipping_end_fact_datetime,ss.shipping_start_fact_datetime)) AS full_day_at_shipping,
	   CASE 
		   WHEN ss.shipping_end_fact_datetime > si.shipping_plan_datetime 
		   THEN 1 
		   ELSE 0 
	   END AS is_delay,
	   CASE 
		   WHEN ss.status = 'finished' 
		   THEN 1 
		   ELSE 0 
	   END AS is_shipping_finish,
	   CASE
	   	   WHEN ss.shipping_end_fact_datetime > si.shipping_plan_datetime 
	   	   THEN DATE_PART('day',AGE(ss.shipping_end_fact_datetime,ss.shipping_start_fact_datetime))
	   	   ELSE 0
	   END AS delay_day_at_shipping,
	   si.payment_amount,
	   si.payment_amount * (scr.shipping_country_base_rate + sa.agreement_rate + st.shipping_transfer_rate) AS vat,
	   si.payment_amount * sa.agreement_commission AS profit
FROM shipping_info si
JOIN shipping_transfer st USING(transfer_type_id)
JOIN shipping_country_rates scr USING(shipping_country_id)
JOIN shipping_agreement sa USING(agreementid)
JOIN shipping_status ss USING(shippingid)