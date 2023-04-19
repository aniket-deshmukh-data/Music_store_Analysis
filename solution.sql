/* create database music_store_database */
/* retore all files from dataset */
/* start answering of given questions*/

/* Q 1. Who is the senior most employee based on job title? */
select employee_id,first_name,last_name,title from employee
order by levels desc
limit 1

/* Q 2. Which countries have the most Invoices? */
select count(*),billing_country from invoice
group by billing_country
order by count(*) desc

/* Q 3. What are top 3 values of total invoice?	*/
select * from invoice
order by total desc
limit 3

/* Q 4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals?	*/
select billing_city, sum(total) from invoice
group by billing_city
order by sum(total) desc
limit 1

/* Q 5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money?	*/
select customer.customer_id as id, customer.first_name as firstname, customer.last_name as lastname,
sum(invoice.total) as total_spent
from customer
join invoice  on customer.customer_id = invoice.customer_id
group by id
order by sum(invoice.total) desc
limit 1

/* Q 6. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A */
select distinct customer.email,customer.first_name,customer.last_name
from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
order by customer.email

/* Q 7. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */
select artist.name,count(track.track_id)
from artist
join album on artist.artist_Id = album.artist_id
join track on track.album_id = album.album_id
join genre on genre.genre_id = track.genre_id
WHERE genre.name like 'Rock'
group by artist.name
order by count(track.track_id) DESC
limit 10

/* Q 8. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first */
select name, milliseconds from track
where milliseconds>
(select avg(milliseconds) from track)
order by milliseconds desc

/* Q 9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/
/* Q 9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/
with best_selling_artist as (
 select artist.artist_id as artist_id, artist.name as artist_name,
	sum(invoice_line.unit_price*invoice_line.quantity)as total_price
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1 
)

select c.customer_id as ID, c.first_name as first_name, c.Last_name as last_name, bsa.artist_name as Artist_name,
sum(il.quantity*il.unit_price) as Amount_selling
from customer c
join invoice as i  on i.customer_id = c.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist  bsa on bsa.artist_id= alb.artist_id 
GROUP by 1 ,2, 3, 4
order by 5 desc

/* Q 10. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres */
with popular_genre as (
 select count(invoice_line.quantity) as purchased_quantity,customer.country as country,
	genre.name as genre_name, genre.genre_id,
	ROW_Number() over(partition by customer.country order by count(invoice_line.quantity) DESC) as RowNO
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)

select * from popular_genre
where RowNo <= 1

/* Q 11. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount */
with recursive
 customer_with_country as(
select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending
	 from invoice
	 join customer on invoice.customer_id=customer.customer_id
	 group by 1,2,3,4
	 order by 2,3 desc
 ),
 country_max_spending as(
 select billing_country, max(total_spending) as max_spending
	 from customer_with_country	
	 group by billing_country
 )
 
 select cc.billing_country,cc.total_spending,cc.first_name,cc.last_name,cc.customer_id
 from customer_with_country cc
 join country_max_spending cs on cc.billing_country=cs.billing_country
 where cc.total_spending=cs.max_spending
 order by 1




