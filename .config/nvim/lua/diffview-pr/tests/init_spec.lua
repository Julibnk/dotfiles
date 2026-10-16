local reconcile = require("diffview-pr").reconcile

describe("reconcile", function()
  it("returns no marks and no writes for empty inputs", function()
    assert.are.same({ viewed = {}, writes = {} }, reconcile({ head_sha = "abc" }))
    assert.are.same({ viewed = {}, writes = {} }, reconcile({ head_sha = "abc", gh_states = {} }))
  end)

  it("marks only the files GitHub shows as viewed", function()
    local result = reconcile({
      head_sha = "abc",
      gh_states = { ["a.lua"] = "VIEWED", ["b.lua"] = "UNVIEWED", ["c.lua"] = "DISMISSED" },
    })

    assert.are.same({ "a.lua" }, result.viewed)
    assert.are.same({}, result.writes)
  end)

  it("keeps local marks on files the PR does not have", function()
    local result = reconcile({
      head_sha = "abc",
      gh_states = { ["a.lua"] = "UNVIEWED" },
      entry = { head_sha = "abc", viewed = { "local-only.lua" }, pending = {} },
    })

    assert.are.same({ "local-only.lua" }, result.viewed)
  end)

  it("drops local marks saved for an older PR head", function()
    local result = reconcile({
      head_sha = "new",
      gh_states = { ["a.lua"] = "UNVIEWED" },
      entry = { head_sha = "old", viewed = { "local-only.lua" }, pending = {} },
    })

    assert.are.same({}, result.viewed)
  end)

  it("resends a pending mark that GitHub never got", function()
    local result = reconcile({
      head_sha = "abc",
      gh_states = { ["a.lua"] = "UNVIEWED" },
      entry = { head_sha = "abc", viewed = { "a.lua" }, pending = { ["a.lua"] = true } },
    })

    assert.are.same({ "a.lua" }, result.viewed)
    assert.are.same({ ["a.lua"] = true }, result.writes)
  end)

  it("skips pending writes that GitHub already matches", function()
    local result = reconcile({
      head_sha = "abc",
      gh_states = { ["a.lua"] = "VIEWED", ["b.lua"] = "DISMISSED" },
      entry = { head_sha = "abc", viewed = { "a.lua" }, pending = { ["a.lua"] = true, ["b.lua"] = false } },
    })

    assert.are.same({ "a.lua" }, result.viewed)
    assert.are.same({}, result.writes)
  end)

  it("never sends writes for files the PR does not have", function()
    local result = reconcile({
      head_sha = "abc",
      gh_states = { ["a.lua"] = "UNVIEWED" },
      entry = { head_sha = "abc", viewed = { "local-only.lua" }, pending = { ["local-only.lua"] = true } },
    })

    assert.are.same({ "local-only.lua" }, result.viewed)
    assert.are.same({}, result.writes)
  end)

  it("uses local marks and keeps every pending write when GitHub is unreachable", function()
    local result = reconcile({
      head_sha = "abc",
      entry = { head_sha = "abc", viewed = { "a.lua", "b.lua" }, pending = { ["b.lua"] = true, ["c.lua"] = false } },
    })

    assert.are.same({ "a.lua", "b.lua" }, result.viewed)
    assert.are.same({ ["b.lua"] = true, ["c.lua"] = false }, result.writes)
  end)

  it("lets GitHub win over local marks on PR files", function()
    local result = reconcile({
      head_sha = "abc",
      gh_states = { ["a.lua"] = "UNVIEWED", ["b.lua"] = "DISMISSED" },
      entry = { head_sha = "abc", viewed = { "a.lua", "b.lua" }, pending = {} },
    })

    assert.are.same({}, result.viewed)
    assert.are.same({}, result.writes)
  end)

  it("resends a pending unmark that GitHub never got", function()
    local result = reconcile({
      head_sha = "abc",
      gh_states = { ["a.lua"] = "VIEWED" },
      entry = { head_sha = "abc", viewed = {}, pending = { ["a.lua"] = false } },
    })

    assert.are.same({}, result.viewed)
    assert.are.same({ ["a.lua"] = false }, result.writes)
  end)

  it("keeps pending writes across a PR head change", function()
    local result = reconcile({
      head_sha = "new",
      gh_states = { ["a.lua"] = "UNVIEWED" },
      entry = { head_sha = "old", viewed = { "a.lua" }, pending = { ["a.lua"] = true } },
    })

    assert.are.same({ "a.lua" }, result.viewed)
    assert.are.same({ ["a.lua"] = true }, result.writes)
  end)
end)
