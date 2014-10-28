wtf-tools
=========

Some tools for debugging and profiling Ruby on Rails projects. Included:

* data dumper 
* code timing tool
* method tracker - a kind of middle ground between simple timing and full profiling
* SQL tracker - detect where exactly given SQL query originated from

User is responsible for requiring gems necessary for rendering output. 
For example, when `:yaml` option is used with `WTF?`, we expect that `YAML` is already loaded.
Library requirements for specific options are documented below.

Usage examples
--------------

### Data dumping

```ruby
WTF? my_var                                   # basic
WTF? my_var, other_var, { some: data }, :pp   # more data, option: pretty-print
WTF? :label, records, :bare, :time            # multiple options given
```

Supported options

```
Prefix
  (default)  WTF (my_file_name/method_name:227): 
  :time      with timestamp: [2014-10-28 12:33:11 +0200]
  :nl        new line before the record
  :no        no prefix at all

Formatting
  (default)  simple Ruby inspect
  :pp        pretty-print, require 'pp'
  :yaml      YAML format,  require 'yaml'
  :json      JSON format,  require 'json'
  :csv       CSV format,   require 'csv'
  :text      simple Ruby to_s
  :line      modifier, each object in separate line
  :bare      modifier, ActiveRecord with just id attributs: #<MyClass id: 1234>

Output control
  (default)  to the chosen logger (see configuration)
  :log       to Rails default logger
  :file      to a separate file in configured location
  :page      to a thread variable Thread.current[:wtf]
  :redis     to a Redis list on key 'wtf', expiring in 30min
  :raise     raise the string containing data as exception
```

---

### Code timing

```ruby
class MyClass
  def run_something
    WTF.time {
      # your code
    }
  end
end
```

Output:

```
WTF (my_class/run_something:3): 0.001
```

---

### Method tracking

```ruby
class MyClass
  def run_something
    WTF.track(self)
    # lots of code
    WTF.track_finish
  end
end
```

Additionally, extra classes/modules can be given:

```
WTF.track(self, OtherClass, Helpers)
```

This will create a CSV file in configured location, containing profiling info.
Profiling happens only in the methods of the calling class, and any other given class.

How it works: every method in `MyClass` and `OtherClass` is overridden, adding resource measuring code.
All calls to those methods from the code between `track` and `track_finish` are measured (time and memory).
Sum amounts are written as CSV file, sorted by total time used.

Example output:

```csv
class,method,count,time,heap_mb
,top,0,0.948,0.0
Overview,some_helper,16408,0.351,0.0
Overview,my_records,28,0.172,0.0
Overview,load_data,1,0.166,0.0 
...
```

*Warning:* tracking method calls adds time overhead (somewhere from 10% to 3x, depending on number of times the methods were called).

---

### SQL tracking

```ruby
class MyClass
  def run_something
    WTF.sql %q{SELECT * FROM `my_records` WHERE `attribute`='value' AND `etc`}
    WTF.sql %q{UPDATE `my_records` SET `some_values`=NULL}
    # lots of code
  end
end
```

This will add a `WTF?`-style dump in the default location, containing stacktrace where given SQL statement was generated. SQL must match exactly as strings.

---


Configuration
-------------

Configure WTF before using the above-mentioned facilities. Rails initializers directory is a good place for it.

```ruby
WTF.options = {
  default: Rails.logger,
  files:   "#{Rails.root}/log/wtf",
  redis:   Redis.new,
}

require 'yaml' # to use :yaml option, etc
```

*Requirement:* Ruby 2.0, because the technique used involves module `prepend`-ing, which is not available in Ruby 1.9.

---

License
-------

This is released under the [MIT License](http://www.opensource.org/licenses/MIT).

Sponsors
-------

This gem is sponsored and used by [SameSystem](http://www.samesystem.com)
![SameSystem](http://www.samesystem.com/assets/logo_small.png)
