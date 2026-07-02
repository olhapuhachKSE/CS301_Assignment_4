Explanation

Before creating the index, PostgreSQL performed a Parallel Sequential Scan on the ticket_discounts table, meaning
it had to scan the entire table to find matching records.

After creating index (discount_id, ticket_id), PostgreSQL switched to Index Only Scan, allowing it to locate
the required rows directly through the index without reading the table itself.

The execution time decreased from 340.5 ms to 184.0 ms.

This what i got when did this script 

    explain analyze
    select
    count(distinct t.customer_id) as cust_with_student_disc
    from tickets t
    join ticket_discounts td
        on t.ticket_id = td.ticket_id
    join discounts d
        on td.discount_id = d.discount_id 
        where d.discount_name = 'Student';


    CREATE INDEX idx_ticket_discounts_composite ON ticket_discounts(discount_id, ticket_id);
Result before index

    Aggregate  (cost=4815.06..4815.07 rows=1 width=8) (actual time=257.672..306.026 rows=1.00 loops=1)
    Buffers: shared hit=280520
    ->  Gather Merge  (cost=4694.05..4812.46 rows=1039 width=4) (actual time=238.774..299.803 rows=69817.00 loops=1)
        Workers Planned: 1
        Workers Launched: 1
        Buffers: shared hit=280520
        ->  Sort  (cost=3694.04..3695.57 rows=611 width=4) (actual time=174.079..176.244 rows=34908.50 loops=2)
              Sort Key: t.customer_id
              Sort Method: quicksort  Memory: 1537kB
              Buffers: shared hit=280520
              Worker 0:  Sort Method: quicksort  Memory: 769kB
              ->  Nested Loop  (cost=13.81..3665.76 rows=611 width=4) (actual time=0.180..163.712 rows=34908.50 loops=2)
                    Buffers: shared hit=280513
                    ->  Hash Join  (cost=13.39..3345.69 rows=611 width=4) (actual time=0.141..41.086 rows=34908.50 loops=2)
                          Hash Cond: (td.discount_id = d.discount_id)
                          Buffers: shared hit=1244
                          ->  Parallel Seq Scan on ticket_discounts td  (cost=0.00..2892.30 rows=165030 width=8) (actual time=0.018..12.341 rows=140275.50 loops=2)
                                Buffers: shared hit=1242
                          ->  Hash  (cost=13.38..13.38 rows=1 width=4) (actual time=0.107..0.108 rows=1.00 loops=2)
                                Buckets: 1024  Batches: 1  Memory Usage: 9kB
                                Buffers: shared hit=2
                                ->  Seq Scan on discounts d  (cost=0.00..13.38 rows=1 width=4) (actual time=0.098..0.100 rows=1.00 loops=2)
                                      Filter: ((discount_name)::text = 'Student'::text)
                                      Rows Removed by Filter: 3
                                      Buffers: shared hit=2
                    ->  Index Scan using tickets_pkey on tickets t  (cost=0.42..0.52 rows=1 width=8) (actual time=0.003..0.003 rows=1.00 loops=69817)
                          Index Cond: (ticket_id = td.ticket_id)
                          Index Searches: 69817
                          Buffers: shared hit=279269
    Planning:
     Buffers: shared hit=113 dirtied=1
    Planning Time: 1.567 ms
    Execution Time: 340.539 ms

Result after index

    Aggregate  (cost=3320.13..3320.14 rows=1 width=8) (actual time=183.653..183.654 rows=1.00 loops=1)
      Buffers: shared hit=279466
    ->  Sort  (cost=3314.94..3317.53 rows=1039 width=4) (actual time=178.042..180.174 rows=69817.00 loops=1)
        Sort Key: t.customer_id
        Sort Method: quicksort  Memory: 3073kB
        Buffers: shared hit=279466
        ->  Nested Loop  (cost=0.85..3262.88 rows=1039 width=4) (actual time=0.120..166.659 rows=69817.00 loops=1)
              Buffers: shared hit=279463
              ->  Nested Loop  (cost=0.42..2718.59 rows=1039 width=4) (actual time=0.109..16.487 rows=69817.00 loops=1)
                    Buffers: shared hit=195
                    ->  Seq Scan on discounts d  (cost=0.00..13.38 rows=1 width=4) (actual time=0.067..0.072 rows=1.00 loops=1)
                          Filter: ((discount_name)::text = 'Student'::text)
                          Rows Removed by Filter: 3
                          Buffers: shared hit=1
                    ->  Index Only Scan using idx_ticket_discounts_composite on ticket_discounts td  (cost=0.42..2003.84 rows=70138 width=8) (actual time=0.039..11.679 rows=69817.00 loops=1)
                          Index Cond: (discount_id = d.discount_id)
                          Heap Fetches: 0
                          Index Searches: 1
                          Buffers: shared hit=194
              ->  Index Scan using tickets_pkey on tickets t  (cost=0.42..0.52 rows=1 width=8) (actual time=0.002..0.002 rows=1.00 loops=69817)
                    Index Cond: (ticket_id = td.ticket_id)
                    Index Searches: 69817
                    Buffers: shared hit=279268
    Planning:
     Buffers: shared hit=153
    Planning Time: 1.716 ms
    Execution Time: 184.041 ms