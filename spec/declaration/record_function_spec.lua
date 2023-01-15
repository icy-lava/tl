local util = require("spec.util")

describe("record function", function()
   describe("redeclaration: ", function()
      it("an inconsistent arity in redeclaration produces an error", util.check_type_error([[
         local record Y
         end

         function Y.do_x(a: integer, b: integer): integer
             return a + b
         end

         function Y.do_x(a: integer): integer
             return Y.do_x(a, 1)
         end
      ]], {
         { y = 8, msg = "type signature of 'do_x' does not match its declaration in Y: different number of input arguments: got 1, expected 2" },
      }))

      it("an inconsistent type in declaration produces an error", util.check_type_error([[
         local record Y
            do_x: function(integer, integer): integer
         end

         function Y.do_x(a: integer, b: string): integer
             return a + math.tointeger(b)
         end
      ]], {
         { y = 5, msg = "type signature of 'do_x' does not match its declaration in Y: argument 2: got string, expected integer" },
      }))

      it("an inconsistent type in redeclaration produces an error", util.check_type_error([[
         local record Y
         end

         function Y.do_x(a: integer, b: integer): integer
             return a + b
         end

         function Y.do_x(a: integer, b: string): integer
             return a + math.tointeger(b)
         end
      ]], {
         { y = 8, msg = "type signature of 'do_x' does not match its declaration in Y: argument 2: got string, expected integer" },
      }))

      it("a consistent redeclaration produces a warning", util.check_warnings([[
         local record Y
         end

         function Y.do_x(a: integer, b: integer): integer
             return a + b
         end

         function Y.do_x(a: integer, b: integer): integer
             return a - b
         end
      ]], {
         { y = 8, msg = "redeclaration of function 'do_x'" },
      }))

      it("a type signature does not count as a redeclaration", util.check_warnings([[
         local record Y
            do_x: function(integer, integer): integer
         end

         function Y.do_x(a: integer, b: integer): integer
             return a + b
         end
      ]], {}, {}))

      it("a type signature does not count as a redeclaration, but catches inconsistency", util.check_warnings([[
         local record Y
            do_x: function(Y, integer, integer): integer
         end

         function Y.do_x(a: integer, b: integer): integer
             return a + b
         end
      ]], {}, {
         { y = 5, msg = "different number of input arguments: got 2, expected 3" },
      }))
   end)
end)
