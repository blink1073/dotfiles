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

const GUARDED_PREFIXES = ["gh pr create", "git push"]

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
    for (const prefix of GUARDED_PREFIXES) {
      if (trimmed === prefix || trimmed.startsWith(prefix + " ")) return prefix
    }
  }
  return undefined
}

export const ClaudeHooks: Plugin = async () => {
  let userMessages = 0
  const seenUserMessages = new Set<string>()
  const blockedAt = new Map<string, number>()

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
      const blocked = blockedAt.get(prefix)
      if (blocked === undefined || blocked >= userMessages) {
        blockedAt.set(prefix, userMessages)
        throw new Error(
          `${prefix} is blocked pending explicit user confirmation. Do not retry yet: show the exact command to the user and ask them to confirm. After the user replies in chat, retry the command once.`,
        )
      }
      blockedAt.delete(prefix)
    },
    event: async ({ event }) => {
      if (event.type !== "message.updated") return
      const info = (event.properties as { info?: { id?: string; role?: string; summary?: unknown } }).info
      if (!info || info.role !== "user" || info.summary !== undefined || typeof info.id !== "string") return
      if (seenUserMessages.has(info.id)) return
      seenUserMessages.add(info.id)
      userMessages += 1
    },
  }
}

export default ClaudeHooks
