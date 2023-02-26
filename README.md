# Crosscourt API

## How to use

1. Clone this repo
2. Install PostgreSQL in case you don't have it
3. Create your `database.yml` and `application.yml` file
4. `bundle install`
5. Generate a secret key with `rake secret` and paste this value into the `application.yml`.
6. `rake db:create`
7. `rake db:migrate`
8. `rspec` and make sure all tests pass
9. `rails s`
10. You can now try your REST services!

## Documentation

---

**Glossary**

- **Date:** only a date `'31/3/2020'`
- **Time:** only a time `'19:50:00 UTC'`
- **DateTime:** both date and time `'Thu, 05 Mar 2020 17:47:33 UTC'`
- **Boolean:** True or False

---

## Models

### AdminUser

Represents an admin capable of signing in to the admin site.

#### Attributes

- **id** (Number: unique)
- **email** (Text: unique)

### Session

Represents the actual game that takes place once or recurrently in a specific location and time.

#### Attributes

- **id** (Number: unique)
- **start_time** (Date: represents the date when the session should starts. It will only accept future values in the admin)
- **recurring** (Text: Represents the recurring rule. e.g: _Weekly on weekdays_)
- **location_id** (Number: id of the location where the session takes place)
- **end_time** (Same as start_time but for the end date)
- **level** (Number: `'0 -> basic, 1 -> advanced'`)

### SessionException

Represents an exception on the recurring rule of the session. The Session will not take place on the SessionException date.

#### Attributes

- **id** (Number: unique)
- **session_id** (Number: id of the session)
- **date** (Date: date when the session is not supposed to occurr)

### Location

Represents a basketball court.

#### Attributes

- **id** (Number: unique)
- **name** (Text: name of the court. Could be the gym name)
- **address** (Text)
- **lat** (Number: latitude of the court. This field is auto assigned when creating a Location in the admin)
- **lng** (Number: longitude of the court. This field is auto assigned when creating a Location in the admin)
- **city** (Text)
- **zipcode** (Text)
- **time_zone** (Text: all times are calculated depending on this _time_zone_)
- **state** (Text)
- **description** (Text)

### User

### Attributes

- **id** (Number: unique)
- **email** (Text: unique)
- **sign_in_count** (Number: the times the user logged in)
- **confirmed_at** (DateTime: the date and time when the user confirmed their email)
- **first_name** (Text)
- **last_name** (Text)
- **phone_number** (Text)
- **credits** (Number: amount of credits available)
- **is_referee** (Boolean)
- **is_sem** (Boolean)
- **stripe_id** (Text: id of the customer created on stripe. This attribute is created when a user signs up)
- **free_session_state** (Number: `'0 -> not_claimed, 1 -> claimed, 2 -> used'`)
- **free_session_payment_intent** (Text: Stripe payment intent created to charge the user if the he doesn't show up)
- **zipcode** (Text)
- **free_session_expiration_date** (Date)

### UserSession

Represents a reservation made by a User to a Session.

#### Attribtues

- **id** (Number: unique)
- **user_id** (Number: id of the user)
- **session_id** (Number: id of the session)
- **state** (Number: `'0 -> reserved, 1 -> canceled, 2 -> confirmed'`)
- **created_at** (DateTime: when the reservation was made)
- **date** (Date of the session)
- **checked_in** (Boolean: if the player was checked in to the session)
- **is_free_session** (Boolean: if this session was reserved using the free credit)
- **free_session_payment_intent** (Text: Same as the user)
- **credit_reimbursed** (Boolean: if a credit was reimbursed to the user after cancellation)

### RefereeSession

Represents an assignment of a Referee in a Session

#### Attributes

- **id** (Number: unique)
- **user_id** (Number: id of the referee)
- **session_id** (Number: id of the session)
- **date** (Date of the session when the referee is assigned)
- **state** (Number: `'0 -> unconfirmed, 1 -> canceled, 2 -> confirmed'`)

### SemSession

Represents an assignment of a SEM in a Session

#### Attributes

- **id** (Number: unique)
- **user_id** (Number: id of the SEM)
- **session_id** (Number: id of the session)
- **date** (Date of the session when the SEM is assigned)
- **state** (Number: `'0 -> unconfirmed, 1 -> canceled, 2 -> confirmed'`)

### Product

Represents one of the Series. e.g: `'The DROP-IN: 1 credit for $15'`

#### Attributes

- **id** (Number: unique)
- **credits** (Number: amount of credits the product will give to the user)
- **name** (Text: name of the product. e.g: `'The DROP-IN'`)
- **price** (Number: amount in dollars)
- **order_number** (Number: `0` will be displayed first in the web)
- **stripe_price_id** (String: Stripe price ID)

### PromoCode

Represents a Discount that a User can apply when making a purchase. There are 2 options. Both have the same attributes.

**SpecificAmountDiscount** e.g: \$10 Discount

**PercentageAmountDiscount** e.g: %10 Discount

#### Attribtues

- **id** (Number: unique)
- **type** (Text: `'SpecificAmountDiscount' or 'PercentageDiscount'`)
- **discount** (Number: The amount to be discounted. If it's a specific amount it will be the amount of dollars. If it's a percentage discount then it will be the percentage)
- **code** (Text: the text that the user needs to input to get the discount. e.g: `'10DollarDiscount'`)
- **expiration_date** (Date)

### UserPromoCode

Represents a usage of the Promo code by the user. Users can only use a promo code once.

**SpecificAmountDiscount** e.g: \$10 Discount

**PercentageAmountDiscount** e.g: %10 Discount

#### Attribtues

- **id** (Number: unique)
- **user_id** (Text: `'SpecificAmountDiscount' or 'PercentageDiscount'`)

### Payment

Represents an actual payment made by a User.

#### Attributes

- **id** (Number: unique)
- **product_id** (Number: id of the product. Could be `null` if the product is deleted after the payment)
- **user_id** (Number: id of the user that made the payment)
- **price** (Number: The price of the payment)
- **name** (Text: name of the product)
- **created_at** (DateTime: when the payment was made)
- **discount** (Number: discount in dollars applied to the payment)

### Legal

Represents a legal document to be displayed in the web.

#### Attributes

- **id** (Number: unique)
- **title** (Text: `'terms_and_conditions' or 'cancelation_policy'`)
- **text** (Text: The complete text of the document)

---

## Integrations

### ActiveCampaign

This integration is used to keep a record of the actions done by a User.

### Sendgrid

This integration is used to send emails from the backend.

This is used for:

- Email confirmation
- Forgot password

---

## Background jobs

Tasks that run recurringly every X amount of time.

**charge_no_show_up_players**

Charges the players that reserved but didn't show up. Applies to free_sessions & unlimited users.

Runs Daily at 12:00 AM UTC

**session_reminders**

Runs Hourly at :00

**confirm_unconfirmed_sessions**

Confirms the UserSessions that didn't confirmed assistance when the confirmation window is closed.

Runs Hourly at "00

## Code quality

With `rake code_analysis` you can run the code analysis tool, you can omit rules with:

- [Rubocop](https://github.com/bbatsov/rubocop/blob/master/config/default.yml) Edit `.rubocop.yml`
- [Reek](https://github.com/troessner/reek#configuration-file) Edit `config.reek`
- [Rails Best Practices](https://github.com/flyerhzm/rails_best_practices#custom-configuration) Edit `config/rails_best_practices.yml`
- [Brakeman](https://github.com/presidentbeef/brakeman) Run `brakeman -I` to generate `config/brakeman.ignore`
- [Bullet](https://github.com/flyerhzm/bullet#whitelist) You can add exceptions to a bullet initializer or in the controller

## Configuring Code Climate

1. After adding the project to CC, go to `Repo Settings`
2. On the `Test Coverage` tab, copy the `Test Reporter ID`
3. Replace the current value of `CC_TEST_REPORTER_ID` on the `config.yml file (.circleci/config.yml)` with the one you copied from CC

## Code Owners

You can use [CODEOWNERS](https://help.github.com/en/articles/about-code-owners) file to define individuals or teams that are responsible for code in the repository.

Code owners are automatically requested for review when someone opens a pull request that modifies code that they own.

## Credits

Rails Api Base is maintained by [Rootstrap](http://www.rootstrap.com) with the help of our
[contributors](https://github.com/rootstrap/rails_api_base/contributors).

[<img src="https://s3-us-west-1.amazonaws.com/rootstrap.com/img/rs.png" width="100"/>](http://www.rootstrap.com)
