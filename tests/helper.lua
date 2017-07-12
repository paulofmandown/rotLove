local say = require 'say'

say:set("assertion.gt.positive", "Expected %s to be greater than %s")
say:set("assertion.gt.negative", "Expected %s not to be greater than %s")
say:set("assertion.lt.positive", "Expected %s to be less than %s")
say:set("assertion.lt.negative", "Expected %s not to be less than %s")
say:set("assertion.undef.positive", "Expected %s to be nil")
say:set("assertion.undef.negative", "Expected %s not to be nil")

