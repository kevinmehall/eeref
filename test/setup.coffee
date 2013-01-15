util = require 'util'
inspect = (o) -> util.inspect o, no, 5, no

global[name] = func for name, func of require 'assert'
global.eq = (a, b) -> equal inspect(a), inspect(b)