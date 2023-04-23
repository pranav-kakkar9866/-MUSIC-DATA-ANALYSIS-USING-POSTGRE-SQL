Q1.) Who is the senior most employee based on job title?

select * from employee

select *  from employee
order by levels desc limit 1

Q2.) Which countries have the most Invoices?

select * from invoice

select count(billing_country),billing_country
 from invoice
group by billing_country
order by billing_country desc

Q3.) What are top 3 values of total invoice?

select billing_country,total from invoice
order by 2 desc
limit 3

Q4.) Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money.
Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals.

select billing_city,sum(total) from invoice
group by 1
order by 2 desc
limit 3

Q5.)Who is the best customer? The customer who has spent the most money will be
declared the best customer. 
Write a query that returns the person who has spent the most money.

select c.ci=ustomer_id,c.first_name,c.last_name,sum(i.total) from invoice as i 
inner join customer as c on i.customer_id=c.customer_id
group by 1,2
order by 3 desc
limit 1

INTERMEDIATE QUESTIONS

#Q1.) Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A


select * from track
select * from genre
select * from invoice_line
select * from invoice

SELECT  distinct c.first_name,c.last_name,c.email from customer as c
inner join invoice as i on c.customer_id=i.customer_id 
inner join invoice_line on i.invoice_id=invoice_line.invoice_id
inner join track  on invoice_line.Track_id=Track.Track_id
inner join genre  on track.genre_id=genre.genre_id 
where genre.name like 'Rock'
order by email

#ANOTHER WAY

SELECT  distinct c.first_name,c.last_name,c.email from customer as c
inner join invoice as i on c.customer_id=i.customer_id 
inner join invoice_line on i.invoice_id=invoice_line.invoice_id
where track_id in (
select track.track_id from track 
inner join genre  on track.genre_id = genre.genre_id
where genre.name like 'Rock' )
order by email

#Q2).Let's invite the artists who have written the most rock music in our dataset.
Write a query that returns the Artist name and total track count of the top 10 rock bands.


select artist.artist_id,artist.name,count(album.artist_id) as number_of_rocks
from artist inner join album on artist.artist_id=album.artist_id
inner join track on album.album_id=track.album_id
inner join  genre on track .genre_id=genre.genre_id
where genre.name like 'Rock'
group  by  artist.artist_id 
order by number_of_rocks desc
limit 10


#Q3. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first

select * from track
select * from genre
select * from invoice_line
select * from invoice
select * from artist
select * from playlist_track
select * from album

SELECT name,milliseconds from track 
where milliseconds>(select avg(milliseconds) from track)
order by milliseconds desc

#COMPLEX QUESTIONS

Q1.) Find how much amount spent by each customer on famous artists? Write a query to return
customer name, artist name and total spent.

select * from customer
select * from artist
select * from invoice_line

with best_selling_artist as (
select artist.artist_id,artist.name as artist_name,sum(il.unit_price*il.quantity) as total_spent from artist
inner join album on artist.artist_id=album.artist_id
inner join track on album.album_id=track.album_id
inner join invoice_line as il on  track.track_id=il.track_id
inner join invoice on il.invoice_id=invoice.invoice_id
inner join customer as c on  invoice.customer_id=c.customer_id
group by 1,2
order by 3 desc
limit 1
)

select c.customer_id,c.first_name,c.last_name,artist.artist_id,artist.name as artist_name,sum(il.unit_price*il.quantity) as total_spent from artist
inner join album on artist.artist_id=album.artist_id
inner join track on album.album_id=track.album_id
inner join invoice_line as il on  track.track_id=il.track_id
inner join invoice on il.invoice_id=invoice.invoice_id
inner join customer as c on  invoice.customer_id=c.customer_id
inner join best_selling_artist as bsa on artist.name=bsa.artist_name 
group by 1,2,3,4,5
order by 6 desc


#Another way
part-1
select artist.artist_id,artist.name as artist_name,sum(il.unit_price*il.quantity) as total_spent from artist
inner join album on artist.artist_id=album.artist_id
inner join track on album.album_id=track.album_id
inner join invoice_line as il on  track.track_id=il.track_id
inner join invoice on il.invoice_id=invoice.invoice_id
inner join customer as c on  invoice.customer_id=c.customer_id
group by 1,2
order by 3 desc
limit 1

part-2
select c.first_name,c.last_name,artist.name as artist_name,sum(il.unit_price*il.quantity) as total_spent from artist
inner join album on artist.artist_id=album.artist_id
inner join track on album.album_id=track.album_id
inner join invoice_line as il on  track.track_id=il.track_id
inner join invoice on il.invoice_id=invoice.invoice_id
inner join customer as c on  invoice.customer_id=c.customer_id
where artist.name like 'Queen'
group by 1,2,3
order by 4 desc



Q2.)We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres.

select * from genre

with popular_genre as(
select count(il.quantity) as high_purchase,c.country,g.genre_id,g.name as genre_name,
row_number() over(partition by c.country order by count(il.quantity)  desc ) as row_no
from invoice_line as il
inner join invoice on il.invoice_id=invoice.invoice_id
inner join customer as c on  invoice.customer_id=c.customer_id
inner join track  on track.track_id=il.track_id
inner join genre as g on track.genre_id=g.genre_id
group by 2,3,4
order by 2 asc, 1 desc 
)

select * from popular_genre where row_no <=1

#Method-2

with recursive 
	popular_genre as(
select count(il.quantity) as high_purchase,c.country,g.genre_id,g.name as genre_name,
row_number() over(partition by c.country order by count(il.quantity)  desc ) as row_no
from invoice_line as il
inner join invoice on il.invoice_id=invoice.invoice_id
inner join customer as c on  invoice.customer_id=c.customer_id
inner join track  on track.track_id=il.track_id
inner join genre as g on track.genre_id=g.genre_id
group by 2,3,4
order by 2 asc, 1 desc 
),
max_genre_per_country as (select max(high_purchase) as max_genre_no,country from popular_genre
group by 2
order by 2)

select popular_genre.* from popular_genre
join max_genre_per_country on popular_genre.country=max_genre_per_country.country
where popular_genre.high_purchase=max_genre_per_country.max_genre_no




Q3.Write a query that determines the customer that has spent the most on music for each
country. 
Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount


select * from invoice

with popular_music as(
select i.billing_country,c.first_name,c.last_name,c.customer_id,sum(i.total) as total_spent,
row_number() over(partition by i.billing_country order by sum(i.total)desc) as  row_no 
from invoice as i
inner join customer as c on i.customer_id=c.customer_id
group by  1,2,3,4
order by 1 asc,5 desc
)

select * from popular_music where row_no <=1

#METHOD-2

with recursive  popular_music as(
	select i.billing_country,c.first_name,c.last_name,c.customer_id,sum(i.total) as total_spent,
row_number() over(partition by i.billing_country order by sum(i.total)desc) as  row_no 
from invoice as i
inner join customer as c on i.customer_id=c.customer_id
group by  1,2,3,4
order by 1 asc,5 desc
),
   max_popular_music as (
	   select billing_country, max(total_spent) as max_sold_music from popular_music
group by 1
order by 1)

select popular_music.* from popular_music
inner join max_popular_music on popular_music.billing_country=max_popular_music.billing_country
where popular_music.total_spent=max_popular_music.max_sold_music











