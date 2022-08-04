##                                Data Analysis on Netflix Movies and TV shows using MS Excel

**Dataset :** Netflix is one of the most popular media and video streaming platforms. They have over 8000 movies or tv shows available on their platform, as of mid-2021, they have over 200M Subscribers globally.

**Data Source:** https://www.kaggle.com/datasets/shivamb/netflix-shows

This tabular dataset consists of listings of all the movies and tv shows available on Netflix, along with details such as - cast, directors, ratings,country, release year, duration, etc.

## Data Cleaning
| Column Name      | Blank Cell Count |
| ----------- | ----------- |
| Country     | 831       |
| cast   | 825        |
| director     | 2634       |
| date_added   | 10        |
| rating     | 4       |
| duration   | 3        |
| show_id     | 0       |
| cast   | 0        |
| type     | 0       |
| title   | 0        |
| release_year     | 0       |
| listed_in   | 0        |
| description   | 0        |
 
## Dealing with the missing data


1.	Country - replacing blank countries with the most common country.I choose to fill all the missing values in "Country" column with mode(frequency).       (USA)

2.	cast - replacing null value with "Data not available"
3.	Director - replacing null value with "Data not available"
4.	Rating- Since rating column has only 4 null values, so let's replace the null values with TV-MA since they give the most amount of rating.

5.	date_added: the missing number is small Since the 'date added' data for the missing values are not readily available on the Internet,I choose to    drop the missing rows.

6.	duration: missing value information available on the internet, So I filled the data from the web.

