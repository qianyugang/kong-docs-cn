-- schema.lua
local typedefs = require "kong.db.schema.typedefs"

return {
  name = "my-custom-plugin",
  fields = {
    {
      config = {
        type = "record",
        fields = {
          {
            environment = {
              type = "string",
              required = true,
              one_of = {
                "production",
                "development"
              }
            }
          },
          {
            server = {
              type = "record",
              fields = {
                {
                  host = typedefs.host {
                    default = "example.default.com"
                  }
                },
                {
                  port = {
                    type = "number",
                    default = 80,
                    between = {
                      0,
                      65534
                    }
                  }
                }
              }
            }
          },
          {
            cache_string = {
              type = "string",
              required = false
            }
          },
          {
            delete_string = {
              type = "string",
              required = false
            }
          }
        }
      }
    }
  }
}
