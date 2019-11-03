from bs4 import BeautifulSoup
import requests
from lxml import etree
import csv
import pandas as pd
import re

# class Venue:
# 	def __init__(self, csv_writer, venue, address, website, event, date, price, link):
# 		self.venue = venue
# 		self.address = address
# 		self.website = website
# 		self.event = event
# 		self.date = date
# 		self.price = price
# 		self.link = link
# 		# self.csv_writer = csv_writer

# 	def csv_add(self):
# 		return self.csv_writer.writerow([self.venue, self.address, self.website, self.event, self.date, self.price, self.link])


# class Employee:

#     def __init__(self, first, last, pay):
#         self.first = first
#         self.last = last
#         self.email = first + '.' + last + '@email.com'
#         self.pay = pay

#     def fullname(self):
#         return '{} {}'.format(self.first, self.last)

# emp_1 = Employee('Corey', 'Schafer', 50000)
# emp_2 = Employee('Test', 'Employee', 60000)

postcode_pattern = re.compile(r'[A-Z]{,2}[0-9]{,2}?\s[0-9][A-Z]{2}', re.IGNORECASE)

# -----------------------------------------------------------------
# -----------------------------------------------------------------
# 						LEXINGTON
# -----------------------------------------------------------------
# -----------------------------------------------------------------

lex_venue = 'The Lexington'

lex_site = 'http://thelexington.co.uk/events.php'
source = requests.get(lex_site).text

soup = BeautifulSoup(source, 'lxml')

lex_location = soup.find('div', class_='subheader').text.strip()

sequence = lex_location

try:
	lex_postcode = postcode_pattern.search(lex_location).group(0)
except Exception as e:
	lex_postcode = ""

event = list()
date = list()
price = list()
link = list()

for i in soup.find_all('h2'):
	try:
		event.append(i.text.strip())
	except Exception as e:
		event.append("")
	try:
		date.append(i.next_sibling.strip().strip())
	except Exception as e:
		date.append("")
	try:
		price.append(i.next_sibling.next_sibling.next_sibling.strip())
	except Exception as e:
		price.append("")

row_events = soup.find_all('div', class_='row-events')

for i in row_events:
	if i.find('a', class_='ticket_link') is None:
		link.append("")
	else:
		link.append(i.find('a', class_='ticket_link')['href'])

# # self, venue, address, website, event, date, price, link
# lexington = Venue(csv_writer, lex_venue, lex_location, lex_site, event, date, price, link)

lex_dict = {'Event':event,
        'Date':date, 
        'Price':price, 
        'Link': link}

lex_df = pd.DataFrame(lex_dict)

lex_df.to_csv(r'London_gigs.csv', index = None)










