# simple-tickets-search-cli

A ruby implementation for `Zendesk Search` challenge.

## Ruby Version

```
2.7.4
```

Please ensure your ruby version is `2.7.4` prior to run any of the following commands.

## Installation

After checking out the repo, to install dependencies, run the following command in root directory of the repo:

```
bin/setup
```

## Usage

The search interface is implemented via a Ruby scripted `CLI`.

To get a help manual of the search program CLI:

```
bin/search_cli -h
```

To run the search program and read from `STDIN`:

```
bin/search_cli
```

To run the program with `verbose` mode:

```
bin/search_cli -v
```

To exit the search program:

either press

```
Ctrl + D
```

or type

```
quit
```

## Development, Debug And Testing

Run the following command to have an `interactive console` for experiment:

```
bin/console
```

To run tests, run the following command:

```
rspec
```

To validate code styles:

```
rubocop
```

To get code testing coverage, run `rspec` testing first, then run the following command to open coverage web page with your default browser:

```
open coverage/index.html
```

## Assumptions And Tradeoffs

1. Assuming the given tickets/users json data are not super massive that `yajl` JSON parser used in this program can always load data properly without much overhead and loading time delay.

2. By simply traversing all users/tickets json data, the search function basically does an exact value match between the seached value (user input) and the provided json data. For `tags` search value on tickets data, however, the search function assumes that a user input could provide multiple tags delimited by `,`, then the function goes through each ticket's `tags` data and adds a ticket into the final results if all of user input `tags` values are inclueded in the ticket's data. If the given dataset gets massive later, then the search function needs to be modified to introduce searching algorithms to perform better on large dataset.

3. As the provided json data is relatively small, loading those data into some instance varaibles via a json parser is fine and quick for now. If the dataset become massive, then loading all data in one go might be not appropriate. Loading data with batches or streams would be more efficient (the used `yajl` gem is able to support this). To avoid any bad user experience, loading data through a separate thread would be helpful.
