# HairSalonPro

HairSalonPro is a Ruby on Rails application that allows "hair stylists" to manage, schedule, and remind clients about appointments. It uses the Twilio API to send SMS text messages and the Google Calendar API to keep track of scheduling

Heroku: https://safe-cliffs-94901.herokuapp.com

## Usage

### Administator Dashboard
#### Calendar
The default HairSalonPro calendar is on the Admin homepage

#### Adding a customer
On your Admin homepage, click on "Add a new customer". Add their information and the new customer will receive a SMS text message alerting them that they have been added as a customer.

#### Adding an appointment
Go to the Customer's page. Click on "Add a new appointment". HairSalonPro will perform some validations and it will be added to the HairSalonPro calendar. The Customer will be notfied via SMS text message that an appointment has been added.

### Customer
#### Contacing HairSalonPro
Send any text message to (760)235-4121. From there, you should receive a message containing options to do things like view your current appointments and more.

## Author
Aaron Lopez
