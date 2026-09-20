EasyHL7

EasyHL7 is a dbt package for turning raw HL7 v2 messages into
structured, queryable relational models.

Instead of writing a different parser for every feed, EasyHL7 uses
version- and message-specific configuration to reconstruct the hierarchy
of an HL7 message from its ordered segment stream. Feed-specific
deviations can be handled with small configuration overrides in the
consuming dbt project.

Why EasyHL7?

HL7 v2 is an ordered stream of segments, but the meaning of those
segments is hierarchical.

For example, an ORU_R01 message may contain:

MSH
PID
PV1
ORC
OBR
OBX
NTE
OBX
ORC
OBR
OBX

The useful structure is closer to:

PATIENT_RESULT
├── PATIENT
│   ├── PID
│   └── VISIT
│       └── PV1
├── ORDER_OBSERVATION[1]
│   ├── ORC
│   ├── OBR
│   ├── OBSERVATION[1]
│   │   ├── OBX
│   │   └── NTE
│   └── OBSERVATION[2]
│       └── OBX
└── ORDER_OBSERVATION[2]
    ├── ORC
    ├── OBR
    └── OBSERVATION[1]
        └── OBX

EasyHL7 reconstructs that hierarchy and then exposes the groups as
relational dbt models.

Core pipeline

Raw HL7 message
    ↓
split_segments()
    ↓
Ordered segment stream
    ↓
apply_config()
    ↓
Segments + hierarchy sequence columns
    ↓
parse_group()
    ↓
Relational group models with structured segment data

The parsing engine is generic. Message-specific behavior lives in
configuration.

Current support

Initial development includes:

ORU_R01 v2.1-2.6

ORM_O01 v2.1-2.6

DFT_P03 v2.1-2.6

ADT_A01 v2.1-2.6

ADT_A02 v2.1-2.6

ADT_A03 v2.1-2.6

ADT_A08 v2.1-2.6

RAS_O01 v2.3-2.3.1

RAS_O17 v2.4-2.6

MDM_T02 v2.3-2.6

MDM_T08 v2.3-2.6

RDE_O01 v2.1-2.3.1

RDE_O11 v2.4-2.6

BAR_P01 v2.1-2.6

BAR_P02 v2.1-2.6

BAR_P05 v2.3-2.6

BAR_P12 v2.5-2.6

Additional versions and message types can be added by supplying their
message structure configuration.

Installation

Add EasyHL7 to your dbt project's packages.yml.

For local development:

packages:
  - local: ../easyhl7

Then install dependencies:

dbt deps

Basic usage

Assume a seed or source contains one HL7 message per row in a column
named message.

1. Split messages into segments

Create a model such as oru_r01__segments.sql:

{{ config(materialized='table') }}

{% set args = {
    'message_ref': 'v2_1__oru_r01_sample',
    'message_column': 'message'
} %}

{{ easyhl7.split_segments(args) }}

A message such as:

MSH|^~\&|LAB|HOSPITAL|EASYHL7|TEST|20260908120000||ORU^R01|MSG00001|P|2.1
PID|1||PAT001||SMITH^JOHN
PV1|1|I
ORC|RE|ORDER001
OBR|1|ORDER001|LAB001|CBC
OBX|1|NM|HGB^Hemoglobin||14.2|g/dL
NTE|1||Hemoglobin result
OBX|2|NM|WBC^White Blood Cell||7.1|10^9/L
ORC|RE|ORDER002
OBR|1|ORDER002|LAB002|BMP
OBX|1|NM|GLU^Glucose||95|mg/dL

is converted into an ordered segment stream containing values such as:

msg_control_id
segment_sequence
segment_type
segment

2. Apply the HL7 message hierarchy

Create oru_r01__hierarchy.sql:

{{ config(materialized='table') }}

{% set args = {
    'segment_ref': 'oru_r01__segments',
    'version': '2.1',
    'message_type': 'ORU_R01'
} %}

{{ easyhl7.apply_config(args) }}

EasyHL7 loads the default ORU_R01 v2.1 configuration and assigns
hierarchy sequences.

Example:

segment  patient_seq  visit_seq  order_observation_seq  observation_seq
MSH      0            0          0                      0
PID      1            0          0                      0
PV1      1            1          0                      0
ORC      1            1          1                      0
OBR      1            1          1                      0
OBX      1            1          1                      1
NTE      1            1          1                      1
OBX      1            1          1                      2
ORC      1            1          2                      0
OBR      1            1          2                      0
OBX      1            1          2                      1

A sequence value of 0 means that an instance of that group has not yet
started in the current message hierarchy.

Parsing groups into relational models

Once the hierarchy exists, parse_group() can produce models for
individual HL7 groups.

Observation model

{{ config(materialized='table') }}

{% set args = {
    'hierarchy_ref': 'oru_r01__hierarchy',
    'version': '2.1',
    'message_type': 'ORU_R01',
    'group': 'OBSERVATION'
} %}

{{ easyhl7.parse_group(args) }}

Because observation sequences restart under each order, EasyHL7 includes
the necessary ancestor sequence in the relational key:

msg_control_id | order_observation_seq | observation_seq | obx | nte
MSG00001       | 1                     | 1               | ... | ...
MSG00001       | 1                     | 2               | ... | ...
MSG00001       | 2                     | 1               | ... | ...

The same generic macro can create other group models:

{% set args = {
    'hierarchy_ref': 'oru_r01__hierarchy',
    'version': '2.1',
    'message_type': 'ORU_R01',
    'group': 'PATIENT'
} %}

{{ easyhl7.parse_group(args) }}

No ORU-specific parsing macro is required.

Structured HL7 segment values

EasyHL7 preserves the internal structure of HL7 fields instead of
requiring a fixed field count.

HL7 delimiter levels are interpreted as:

|  field
~  repetition
^  component
&  subcomponent

For example:

OBX|1|NM|HGB^Hemoglobin||14.2|g/dL

can be represented as structured JSON:

{
  "1": "1",
  "2": "NM",
  "3": {
    "1": "HGB",
    "2": "Hemoglobin"
  },
  "4": "",
  "5": "14.2",
  "6": "g/dL"
}

A value such as:

Michael^Smith

becomes:

{
  "1": "Michael",
  "2": "Smith"
}

And deeper structures can be preserved:

ABC^Michael&Joseph^Smith

{
  "1": "ABC",
  "2": {
    "1": "Michael",
    "2": "Joseph"
  },
  "3": "Smith"
}

Repeating fields using ~ are represented as arrays.

Repeating segments

Segment cardinality comes from the HL7 message configuration.

A non-repeating segment such as OBX within an OBSERVATION group can be
returned as one JSON object.

A repeating segment such as NTE is preserved as an array:

[
  {
    "1": "1",
    "2": "",
    "3": "First note"
  },
  {
    "1": "2",
    "2": "",
    "3": "Second note"
  }
]

EasyHL7 does not arbitrarily select the first repeated segment or
discard distinct repetitions.

Configuration-driven hierarchy

Message configurations describe the HL7 grammar.

A simplified ORU_R01 group might look like:

{
    "type": "group",
    "name": "ORDER_OBSERVATION",
    "min": 1,
    "max": none,
    "anchor": ["OBR"],
    "preamble": ["ORC"],
    "children": [
        {
            "type": "segment",
            "name": "ORC",
            "min": 0,
            "max": 1
        },
        {
            "type": "segment",
            "name": "OBR",
            "min": 1,
            "max": 1
        },
        {
            "type": "group",
            "name": "OBSERVATION",
            "min": 1,
            "max": none,
            "anchor": ["OBX"],
            "children": [
                {
                    "type": "segment",
                    "name": "OBX",
                    "min": 1,
                    "max": 1
                },
                {
                    "type": "segment",
                    "name": "NTE",
                    "min": 0,
                    "max": none
                }
            ]
        }
    ]
}

Anchors

An anchor identifies the segment that starts a new instance of a
repeating group.

For example:

anchor: [OBR]

means each OBR starts a new ORDER_OBSERVATION.

Preambles

Some valid segments occur immediately before the most reliable group
anchor.

For example:

"anchor": ["OBR"],
"preamble": ["ORC"]

allows:

ORC
OBR

to be assigned to the same upcoming order group even though OBR is the
segment that identifies the new instance.

Structural entry points

Some HL7 grammars contain groups that can become structurally active without
incrementing a public group occurrence sequence. EasyHL7 represents those
entry points with scope_entry.

An anchor starts a new observable group occurrence and increments its
sequence. A scope_entry establishes structural membership without
incrementing that public occurrence sequence. This distinction allows the
generic parser to handle adjacent or nested grammar branches that may contain
the same segment types without treating every appearance as a new group
instance.

Feed-specific configuration overrides

Real HL7 feeds do not always follow the standard ordering exactly.

EasyHL7 allows a consuming project to override only the part of the
default grammar that differs.

Suppose a nonstandard ORM_O01 feed sends:

OBR
ORC
OBR
ORC

while the default configuration uses ORC as the ORDER anchor.

Create an override macro in the consuming project:

{% macro orm_o01_config_override() %}

    {{ return({
        "ORDER": {
            "anchor": ["OBR"]
        }
    }) }}

{% endmacro %}

Then pass it explicitly to the hierarchy model:

{{ config(materialized='table') }}

{% set args = {
    'segment_ref': 'orm_o01__segments',
    'version': '2.1',
    'message_type': 'ORM_O01',
    'config_override': orm_o01_config_override()
} %}

{{ easyhl7.apply_config(args) }}

The default package configuration remains unchanged.

Without the override, a feed such as:

OBR|1|ORD101||CBC^Complete Blood Count
ORC|NW|ORD101
OBR|1|ORD102||CMP^Comprehensive Metabolic Panel
ORC|NW|ORD102

could be grouped incorrectly when ORC is treated as the ORDER anchor.

With the override, the hierarchy becomes:

segment  order_seq
OBR      1
ORC      1
OBR      2
ORC      2

This lets EasyHL7 support feed-specific deviations without forking or
modifying the package.

Full custom configurations

For feeds that differ substantially from the standard message grammar, a
consuming project can supply a complete configuration instead of a
partial override:

{% set args = {
    'segment_ref': 'orm_o01__segments',
    'config': custom_orm_o01_config()
} %}

{{ easyhl7.apply_config(args) }}

This bypasses the built-in message configuration entirely.

The intended configuration hierarchy is therefore:

EasyHL7 standard config
        ↓
optional feed-specific override
        ↓
generic hierarchy parser

or, when necessary:

full custom config
        ↓
generic hierarchy parser

ORM_O01 example

An ORM_O01 message:

MSH|^~\&|ORDERAPP|HOSPITAL|EASYHL7|TEST|20260913130000||ORM^O01|ORM00001|P|2.1
PID|1||PAT001||SMITH^MICHAEL||19880615|M
PV1|1|O|CLINIC^101^A
ORC|NW|ORD001
OBR|1|ORD001||CBC^Complete Blood Count
ORC|NW|ORD002
OBR|1|ORD002||BMP^Basic Metabolic Panel
DG1|1||Z00.00^General adult medical examination

can be processed using the same three-stage pattern.

Segments

{% set args = {
    'message_ref': 'v2_1__orm_o01_sample',
    'message_column': 'message'
} %}

{{ easyhl7.split_segments(args) }}

Hierarchy

{% set args = {
    'segment_ref': 'orm_o01__segments',
    'version': '2.1',
    'message_type': 'ORM_O01'
} %}

{{ easyhl7.apply_config(args) }}

Orders

{% set args = {
    'hierarchy_ref': 'orm_o01__hierarchy',
    'version': '2.1',
    'message_type': 'ORM_O01',
    'group': 'ORDER'
} %}

{{ easyhl7.parse_group(args) }}

The result contains one relational row per ORDER instance rather than
requiring an ORM-specific parser.

Recommended project organization

A consuming dbt project can organize models by HL7 version and message
type:

models/
└── v2_1/
    ├── oru/
    │   └── r01/
    │       ├── oru_r01__segments.sql
    │       ├── oru_r01__hierarchy.sql
    │       ├── oru_r01__patient.sql
    │       ├── oru_r01__visit.sql
    │       ├── oru_r01__order_observation.sql
    │       └── oru_r01__observation.sql
    └── orm/
        └── o01/
            ├── orm_o01__segments.sql
            ├── orm_o01__hierarchy.sql
            ├── orm_o01__patient.sql
            ├── orm_o01__patient_visit.sql
            └── orm_o01__order.sql

Folder-level dbt configuration can assign schemas and inherited tags:

models:
  easyhl7_dev:

    v2_1:
      +tags:
        - hl7_v2_1

      oru:
        r01:
          +schema: oru_r01
          +tags:
            - oru_r01

      orm:
        o01:
          +schema: orm_o01
          +tags:
            - orm_o01

Then models can be selected with:

dbt run --select tag:hl7_v2_1

or:

dbt run --select tag:orm_o01

An example of how these segments can be tied together for an ORU HL7v2.1 message might look like:

select
    p.msg_control_id,

    p.patient_seq,
    p.pid ->> '3' as patient_id,
    p.pid -> '5' ->> '1' as patient_last_name,
    p.pid -> '5' ->> '2' as patient_first_name,

    v.visit_seq,
    v.pv1 ->> '2' as patient_class,

    o.order_observation_seq,
    o.orc ->> '1' as order_control,
    o.orc ->> '2' as placer_order_number,

    o.obr ->> '2' as obr_placer_order_number,
    o.obr ->> '3' as filler_order_number,
    o.obr ->> '4' as test_code,

    obs.observation_seq,
    obs.obx ->> '2' as value_type,
    obs.obx -> '3' ->> '1' as observation_code,
    obs.obx -> '3' ->> '2' as observation_description,
    obs.obx ->> '5' as observation_value,
    obs.obx ->> '6' as units,
    obs.nte

from {{ ref('oru_r01__patient') }} p

left join {{ ref('oru_r01__visit') }} v
    on p.msg_control_id = v.msg_control_id
    and p.patient_seq = v.patient_seq

left join {{ ref('oru_r01__order_observation') }} o
    on p.msg_control_id = o.msg_control_id

left join {{ ref('oru_r01__observation') }} obs
    on o.msg_control_id = obs.msg_control_id
    and o.order_observation_seq = obs.order_observation_seq

Design principles

EasyHL7 aims to keep a clear separation between:

HL7 grammar - version/message configuration describes groups,
cardinality, anchors, preambles, and children.

Feed-specific behavior - small overrides describe deviations
from the standard.

Parsing engine - generic dbt macros reconstruct hierarchy and
parse groups without knowing message-specific group names.

Consumer models - small dbt models choose which HL7 groups
should become relational tables.

The goal is to make adding a new supported HL7 message primarily a
configuration task rather than another custom parsing implementation.

Development and validation

EasyHL7 is being developed against multiple HL7 v2 message families rather
than a single message shape. The current configuration set exercises nested
repeating groups, parent-scoped sequence numbers, preambles, structural entry
points, optional groups, and version-specific grammar changes.

Regression fixtures are maintained per supported message/version combination
so parser changes can be checked across existing configurations. Patch
releases such as v2.3.1 and v2.5.1 are tested independently even when they
intentionally reuse the preceding version's configuration.

With the parser now exercised across a broad set of message structures, the
next phase of development can focus on the package around it: installation
and package metadata, automated tests and CI, public API stability,
generated-model ergonomics, documentation, contribution guidance, and release
preparation.

Status

EasyHL7 is under active development and is being prepared for its first
open-source release.

The parsing architecture and configuration model are established. Until the
first stable release, the public API, configuration format, supported message
matrix, and output representation should still be considered subject to
change.