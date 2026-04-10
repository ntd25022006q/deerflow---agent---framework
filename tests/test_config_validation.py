"""
Deerflow Agent Framework — MCP Config & JSON Validation Tests
=============================================================
Uses real jsonschema library for validation. No mocks.
"""

import os
import sys
import json
import pytest

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

MCP_CONFIG_PATH = os.path.join(REPO_ROOT, "deerflow", "mcp", "mcp-config.json")
WORKFLOW_PATH = os.path.join(REPO_ROOT, ".github", "workflows", "quality-gate.yml")


# ════════════════════════════════════════════════════════════════════
# GROUP 1: MCP CONFIG STRUCTURE TESTS
# ════════════════════════════════════════════════════════════════════

class TestMCPConfigStructure:
    """Validate MCP config JSON structure and tool definitions."""

    @pytest.fixture(autouse=True)
    def load_config(self):
        with open(MCP_CONFIG_PATH) as f:
            self.config = json.load(f)
        return self.config

    def test_valid_json(self):
        """Config must be parseable JSON."""
        with open(MCP_CONFIG_PATH) as f:
            data = json.load(f)
        assert isinstance(data, dict)

    def test_has_mcp_servers_key(self):
        assert "mcpServers" in self.config, "Missing mcpServers key"

    def test_has_deerflow_governance_server(self):
        assert "deerflow-governance" in self.config["mcpServers"]

    def test_server_has_tools(self):
        server = self.config["mcpServers"]["deerflow-governance"]
        assert "tools" in server
        assert isinstance(server["tools"], list)
        assert len(server["tools"]) >= 7, f"Expected >= 7 tools, got {len(server['tools'])}"

    def test_server_has_resources(self):
        server = self.config["mcpServers"]["deerflow-governance"]
        assert "resources" in server
        assert isinstance(server["resources"], list)
        assert len(server["resources"]) >= 3, f"Expected >= 3 resources, got {len(server['resources'])}"

    def test_server_has_prompts(self):
        server = self.config["mcpServers"]["deerflow-governance"]
        assert "prompts" in server
        assert isinstance(server["prompts"], list)

    def test_all_tools_have_required_fields(self):
        """Every tool MUST have: name, description, inputSchema with type=object."""
        tools = self.config["mcpServers"]["deerflow-governance"]["tools"]
        for tool in tools:
            assert "name" in tool, f"Tool missing 'name': {tool}"
            assert "description" in tool, f"Tool '{tool.get('name')}' missing 'description'"
            assert "inputSchema" in tool, f"Tool '{tool.get('name')}' missing 'inputSchema'"
            schema = tool["inputSchema"]
            assert schema.get("type") == "object", f"Tool '{tool.get('name')}' inputSchema.type must be 'object'"
            assert "properties" in schema, f"Tool '{tool.get('name')}' inputSchema missing 'properties'"
            assert "required" in schema, f"Tool '{tool.get('name')}' inputSchema missing 'required'"

    def test_all_required_props_exist_in_properties(self):
        """Every property in 'required' must exist in 'properties'."""
        tools = self.config["mcpServers"]["deerflow-governance"]["tools"]
        for tool in tools:
            schema = tool["inputSchema"]
            for req in schema["required"]:
                assert req in schema["properties"], \
                    f"Tool '{tool['name']}' requires '{req}' but it's not in properties"

    def test_enum_values_are_non_empty_arrays(self):
        """Any 'enum' in tool properties must have at least one value."""
        tools = self.config["mcpServers"]["deerflow-governance"]["tools"]
        for tool in tools:
            props = tool["inputSchema"].get("properties", {})
            for prop_name, prop_def in props.items():
                if "enum" in prop_def:
                    assert isinstance(prop_def["enum"], list), \
                        f"Tool '{tool['name']}' prop '{prop_name}' enum must be a list"
                    assert len(prop_def["enum"]) >= 1, \
                        f"Tool '{tool['name']}' prop '{prop_name}' enum is empty"

    def test_check_rule_violation_tool_schema(self):
        """Verify check_rule_violation tool has correct structure."""
        tools = {t["name"]: t for t in self.config["mcpServers"]["deerflow-governance"]["tools"]}
        tool = tools["check_rule_violation"]
        props = tool["inputSchema"]["properties"]
        assert "code" in props
        assert "language" in props
        assert props["language"].get("type") == "string"
        assert "typescript" in props["language"].get("enum", [])

    def test_verify_library_tool_schema(self):
        tools = {t["name"]: t for t in self.config["mcpServers"]["deerflow-governance"]["tools"]}
        tool = tools["verify_library"]
        assert "package_name" in tool["inputSchema"]["properties"]
        assert "registry" in tool["inputSchema"]["properties"]
        assert "npm" in tool["inputSchema"]["properties"]["registry"].get("enum", [])

    def test_file_safety_check_tool_schema(self):
        tools = {t["name"]: t for t in self.config["mcpServers"]["deerflow-governance"]["tools"]}
        tool = tools["file_safety_check"]
        assert "operation" in tool["inputSchema"]["properties"]
        assert "delete" in tool["inputSchema"]["properties"]["operation"].get("enum", [])
        assert "file_path" in tool["inputSchema"]["properties"]
        assert "reason" in tool["inputSchema"]["properties"]
        # All three must be required
        reqs = tool["inputSchema"]["required"]
        assert "operation" in reqs
        assert "file_path" in reqs
        assert "reason" in reqs

    def test_quality_gate_check_tool_array_items(self):
        tools = {t["name"]: t for t in self.config["mcpServers"]["deerflow-governance"]["tools"]}
        tool = tools["quality_gate_check"]
        gates_prop = tool["inputSchema"]["properties"].get("gates", {})
        if "items" in gates_prop:
            items_enum = gates_prop["items"].get("enum", [])
            assert len(items_enum) >= 5, f"quality_gate_check should have >= 5 gate options"
            assert "safety" in items_enum
            assert "build" in items_enum
            assert "security" in items_enum

    def test_log_work_tool_required_fields(self):
        tools = {t["name"]: t for t in self.config["mcpServers"]["deerflow-governance"]["tools"]}
        tool = tools["log_work"]
        reqs = tool["inputSchema"]["required"]
        assert "action" in reqs
        assert "files_affected" in reqs
        assert "result" in reqs
        # result should have enum
        result_prop = tool["inputSchema"]["properties"]["result"]
        assert "enum" in result_prop
        assert "success" in result_prop["enum"]
        assert "failure" in result_prop["enum"]

    def test_prompts_have_required_name_description(self):
        prompts = self.config["mcpServers"]["deerflow-governance"]["prompts"]
        for prompt in prompts:
            assert "name" in prompt, "Prompt missing 'name'"
            assert "description" in prompt, f"Prompt '{prompt.get('name')}' missing 'description'"

    def test_resources_have_required_uri_name(self):
        resources = self.config["mcpServers"]["deerflow-governance"]["resources"]
        for resource in resources:
            assert "uri" in resource, "Resource missing 'uri'"
            assert "name" in resource, f"Resource '{resource.get('uri')}' missing 'name'"

    def test_server_has_version(self):
        server = self.config["mcpServers"]["deerflow-governance"]
        assert "version" in server
        # Version should be semver-like
        version = server["version"]
        parts = version.split(".")
        assert len(parts) >= 2, f"Version '{version}' doesn't look like semver"


# ════════════════════════════════════════════════════════════════════
# GROUP 2: JSON SCHEMA VALIDATION (using jsonschema library)
# ════════════════════════════════════════════════════════════════════

class TestMCPConfigSchemaValidation:
    """Validate MCP config against a strict JSON Schema."""

    MCP_SCHEMA = {
        "type": "object",
        "required": ["mcpServers"],
        "properties": {
            "mcpServers": {
                "type": "object",
                "required": ["deerflow-governance"],
                "properties": {
                    "deerflow-governance": {
                        "type": "object",
                        "required": ["description", "version", "tools", "resources", "prompts"],
                        "properties": {
                            "description": {"type": "string", "minLength": 10},
                            "version": {"type": "string", "pattern": r"^\d+\.\d+\.\d+$"},
                            "tools": {
                                "type": "array",
                                "minItems": 7,
                                "items": {
                                    "type": "object",
                                    "required": ["name", "description", "inputSchema"],
                                    "properties": {
                                        "name": {"type": "string", "minLength": 1},
                                        "description": {"type": "string", "minLength": 5},
                                        "inputSchema": {
                                            "type": "object",
                                            "required": ["type", "properties", "required"],
                                            "properties": {
                                                "type": {"const": "object"},
                                                "properties": {"type": "object"},
                                                "required": {"type": "array"},
                                            },
                                        },
                                    },
                                },
                            },
                            "resources": {
                                "type": "array",
                                "minItems": 3,
                                "items": {
                                    "type": "object",
                                    "required": ["uri", "name", "description"],
                                },
                            },
                            "prompts": {
                                "type": "array",
                                "minItems": 2,
                                "items": {
                                    "type": "object",
                                    "required": ["name", "description"],
                                },
                            },
                        },
                    },
                },
            },
        },
    }

    def test_config_passes_schema_validation(self):
        """Validate the entire MCP config against strict JSON Schema."""
        import jsonschema
        with open(MCP_CONFIG_PATH) as f:
            config = json.load(f)
        jsonschema.validate(instance=config, schema=self.MCP_SCHEMA)

    def test_tool_input_schemas_are_valid(self):
        """Each tool's inputSchema must itself be valid JSON Schema."""
        import jsonschema
        with open(MCP_CONFIG_PATH) as f:
            config = json.load(f)
        meta_schema = {
            "type": "object",
            "required": ["type"],
            "properties": {
                "type": {"const": "object"},
                "properties": {"type": "object"},
                "required": {"type": "array"},
            },
        }
        tools = config["mcpServers"]["deerflow-governance"]["tools"]
        for tool in tools:
            jsonschema.validate(
                instance=tool["inputSchema"],
                schema=meta_schema,
            )


# ════════════════════════════════════════════════════════════════════
# GROUP 3: TOOL NAME UNIQUENESS
# ════════════════════════════════════════════════════════════════════

class TestToolNameUniqueness:
    """All tool names must be unique (case-insensitive)."""

    def test_no_duplicate_tool_names(self):
        with open(MCP_CONFIG_PATH) as f:
            config = json.load(f)
        tools = config["mcpServers"]["deerflow-governance"]["tools"]
        names = [t["name"] for t in tools]
        names_lower = [n.lower() for n in names]
        assert len(names_lower) == len(set(names_lower)), \
            f"Duplicate tool names found in: {names}"

    def test_no_duplicate_resource_uris(self):
        with open(MCP_CONFIG_PATH) as f:
            config = json.load(f)
        resources = config["mcpServers"]["deerflow-governance"]["resources"]
        uris = [r["uri"] for r in resources]
        assert len(uris) == len(set(uris)), f"Duplicate resource URIs: {uris}"

    def test_no_duplicate_prompt_names(self):
        with open(MCP_CONFIG_PATH) as f:
            config = json.load(f)
        prompts = config["mcpServers"]["deerflow-governance"]["prompts"]
        names = [p["name"] for p in prompts]
        assert len(names) == len(set(names)), f"Duplicate prompt names: {names}"


# ════════════════════════════════════════════════════════════════════
# GROUP 4: YAML WORKFLOW VALIDATION
# ════════════════════════════════════════════════════════════════════

class TestWorkflowYAMLValidation:
    """Validate CI/CD workflow YAML is structurally correct."""

    def test_yaml_parseable(self):
        import yaml
        with open(WORKFLOW_PATH) as f:
            config = yaml.safe_load(f)
        assert config is not None

    def test_all_jobs_use_ubuntu_runner(self):
        import yaml
        with open(WORKFLOW_PATH) as f:
            config = yaml.safe_load(f)
        for job_name, job_config in config.get("jobs", {}).items():
            if "runs-on" in job_config:
                assert "ubuntu" in str(job_config["runs-on"]), \
                    f"Job '{job_name}' should use ubuntu runner"
