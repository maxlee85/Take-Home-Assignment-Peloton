-- 1.
   select c.customer_id as customer_id
        , c.first_name as first_name
        , c.last_name as last_name
        , c.email as email
        , p.purchase_id as purchase_id
        , p.purchase_time as purchase_time
        , sum(p_i.quantity) as total_quantity
        , sum(p_i.total_amount_paid) as total_amount_paid
     from customer c
left join purchase p on c.customer_id = p.customer_id
left join purchase_item p_i on p.purchase_id = p_i.purchase_id
    where p.purchase_id is not null
 group by 1,2,3,4,5,6

 -- 2.
   select c.customer_id as customer_id
        , c.first_name as first_name
        , c.last_name as last_name
        , c.email as email
        , count(distinct p.purchase_id) as number_of_purchases
     from customer c
left join purchase p on c.customer_id = p.customer_id
 group by 1,2,3,4
   having count(distinct p.purchase_id) > 1
 order by 5 desc

-- 3.
    select p_i.sku as sku
         , count(distinct p.customer_id) as total_number_of_customers
      from purchase p
inner join purchase_item p_i on p.purchase_id = p_i.purchase_id
  group by 1

  -- 4.
  select c.customer_id as customer_id
       , c.first_name as first_name
       , c.last_name as last_name
       , c.email as email
       , sum(p_i.total_amount_paid) as total_amount_paid
    from customer c
left join purchase p on c.customer_id = p.customer_id
left join purchase_item p_i on p.purchase_id = p_i.purchase_id
 group by 1,2,3,4

 -- 5.
 with bike_purchases as (
   select distinct purchase_id from purchase_item where sku like '%bike%'
 )

    select case
             when b_p.purchase_id is not null then True
             else False
           end as is_bike_purchase
         , count(distinct p_i.purchase_id) as num_purchases
         , sum(p_i.total_amount_paid)::decimal/count(distinct p_i.purchase_id) as avg_amount_paid
         , sum(p_i.quantity)::decimal/count(distinct p_i.purchase_id) as avg_number_of_items
      from purchase_item p_i
 left join bike_purchases b_p on p_i.purchase_id = b_p.purchase_id
  group by 1

-- 6.
with purchase_order as (
  select purchase_id
       , customer_id
       , purchase_time
       , row_number() over (partition by customer_id order by purchase_time desc) as rank
    from purchase
)

    select c.customer_id
         , c.first_name
         , c.last_name
         , c.email
         , p_o.purchase_id
         , p_o.purchase_time
         , sum(p_i.quantity) as total_quantity
         , sum(p_i.total_amount_paid) as total_amount_paid
      from customer c
inner join purchase_order p_o on c.customer_id = p_o.customer_id and p_o.rank = 1
inner join purchase_item p_i on p_o.purchase_id = p_i.purchase_id
  group by 1,2,3,4,5,6
