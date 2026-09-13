import type { Plugin } from "@opencode-ai/plugin"
import { spawn } from "node:child_process"
import { homedir } from "node:os"
import path from "node:path"

const HOOKS_DIR = path.join(homedir(), ".claude", "hooks")

const PYTHON_HOOKS = [
  { script: "check_gh_pr.py", gate: /\bgh\s+pr\s+create\b/ },
  { script: "check_git_add.py", gate: /\bgit\s+add\b/ },
  { script: "check_git_commit.py", gate: /\bgit\s+commit\b/ },
]

const ALWAYS_BLOCK_PREFIXES = ["gh pr comment", "gh pr merge"]

const CONFIRM_PREFIXES = ["gh pr create", "git push", "git add", "git commit"]

function confirmWord(prefix: string): string {
  const key = prefix.startsWith("git ") ? prefix.slice("git ".length) : prefix.slice("gh pr ".length)
  return key
}

function runHook(script: string, command: string): Promise<string | undefined> {
  return new Promise((resolve) => {
    const proc = spawn("python3", [path.join(HOOKS_DIR, script)], {
      stdio: ["pipe", "ignore", "pipe"],
    })
    let stderr = ""
    proc.stderr.setEncoding("utf8")
    proc.stderr.on("data", (chunk) => {
      stderr += chunk
    })
    proc.on("error", () => resolve(undefined))
    proc.on("close", (code) => {
      resolve(code === 2 ? stderr.trim() || `${script} rejected this command` : undefined)
    })
    proc.stdin.write(JSON.stringify({ tool_input: { command } }))
    proc.stdin.end()
  })
}

function guardedPrefix(command: string): string | undefined {
  for (const segment of command.split(/&&|\|\||;|\|/)) {
    const trimmed = segment.trim()
    for (const prefix of [...ALWAYS_BLOCK_PREFIXES, ...CONFIRM_PREFIXES]) {
      if (trimmed === prefix || trimmed.startsWith(prefix + " ")) return prefix
    }
  }
  return undefined
}

function extractUserText(parts: Array<{ type?: string; text?: string }>): string {
  return parts
    .filter((p) => p.type === "text" && p.text)
    .map((p) => p.text)
    .join("\n")
}

function isApproval(text: string, prefix: string): boolean {
  const normalized = text.trim().toLowerCase()
  if (normalized === "" || normalized.length > 40) return false
  if (normalized === "yes" || normalized === "y") return true
  return normalized === confirmWord(prefix)
}

export const ClaudeHooks: Plugin = async () => {
  let pendingPrefix: string | undefined

  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool !== "bash") return
      const command = output.args?.command
      if (typeof command !== "string" || command.length === 0) return
      const workdir = output.args?.workdir
      const effective =
        typeof workdir === "string" && workdir.length > 0
          ? `cd ${JSON.stringify(workdir)} && ${command}`
          : command

      for (const { script, gate } of PYTHON_HOOKS) {
        if (!gate.test(effective)) continue
        const rejection = await runHook(script, effective)
        if (rejection) throw new Error(rejection)
      }

      const prefix = guardedPrefix(command)
      if (!prefix) return

      if (ALWAYS_BLOCK_PREFIXES.includes(prefix)) {
        throw new Error(`${prefix} is blocked and cannot be run by the agent.`)
      }

      if (pendingPrefix === prefix) {
        pendingPrefix = undefined
        return
      }

      pendingPrefix = prefix
      throw new Error(
        `${prefix} is blocked pending your confirmation. Show the exact command to the user and ask them to approve it by replying "yes" or "${confirmWord(prefix)}".`,
      )
    },
    "chat.message": async (_input, output) => {
      const text = extractUserText(output.parts)
      if (!pendingPrefix) return
      if (isApproval(text, pendingPrefix)) pendingPrefix = undefined
    },
  }
}

export default ClaudeHooks
