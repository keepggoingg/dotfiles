-- Java / Spring Boot on top of LazyVim's lang.java extra (jdtls, debug, tests).
local sdk = vim.fn.expand("~/.sdkman/candidates/java")

return {
  {
    "mfussenegger/nvim-jdtls",
    -- Recent jdtls needs Java 25+ to run; use Homebrew's keg-only openjdk for the
    -- server only (the shell's `java` and the project JDKs stay on SDKMAN).
    opts = function(_, opts)
      local server_java = "/opt/homebrew/opt/openjdk/bin/java"
      if vim.fn.executable(server_java) == 1 then
        table.insert(opts.cmd, 2, "--java-executable=" .. server_java)
      end
      return vim.tbl_deep_extend("force", opts, {
        settings = {
          java = {
            configuration = {
              -- JDKs projects can compile against; each project picks one from pom.xml / build.gradle.
              runtimes = {
                { name = "JavaSE-17", path = sdk .. "/17.0.19-ms" },
                { name = "JavaSE-21", path = sdk .. "/21.0.9-oracle", default = true },
                { name = "JavaSE-22", path = sdk .. "/22.0.2-oracle" },
              },
              updateBuildConfiguration = "interactive",
            },
            inlayHints = { parameterNames = { enabled = "all" } },
            saveActions = { organizeImports = false },
            completion = {
              favoriteStaticMembers = {
                "org.junit.jupiter.api.Assertions.*",
                "org.mockito.Mockito.*",
                "org.mockito.ArgumentMatchers.*",
                "org.assertj.core.api.Assertions.*",
                "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
                "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
              },
            },
            sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
          },
        },
        -- Add the Spring Boot jdtls extensions to the bundles LazyVim already collects.
        jdtls = function(config)
          local ok, spring = pcall(require, "spring_boot")
          if ok then
            config.init_options = config.init_options or {}
            config.init_options.bundles = config.init_options.bundles or {}
            vim.list_extend(config.init_options.bundles, spring.java_extensions())
          end
          return config
        end,
      })
    end,
  },

  -- Spring Boot language server: application.yml/properties completion,
  -- bean and endpoint navigation, live hovers.
  {
    "JavaHello/spring-boot.nvim",
    ft = { "java", "yaml", "jproperties" },
    dependencies = { "mfussenegger/nvim-jdtls" },
    opts = {},
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "vscode-spring-boot-tools" } },
  },
}
