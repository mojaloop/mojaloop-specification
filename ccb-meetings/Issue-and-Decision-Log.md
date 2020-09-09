---
showToc: false
---
# Issues and Decision Log

### **Work stream:** FSPIOP Change Control Board

Last update - 2019/06/11

### Table Of Content

- [1. Document Purpose](#1-document-purpose)
- [2. Status Summary](#2-status-summary)
- [3. Active List](#3-active-list)
- [4. Completed List](#4-completed-list)

## 1. Document Purpose
___

The purpose of this document is to keep a log of all issues raised and desisions made by the Change Control Board(CCB) forum.

## 2. Status Summary
___

|Status|Count|
|---|---|
|Open||
|Assigned|13|
|Deferred||
|Closed|6|

## 3. Active List
___

|Track Number|Status|Original Workstream|Title|Description|Next Steps|Responsible|Date Identified|Deadline|Date Updated|Date Resolved|
|---|---|---|---|---|---|---|---|---|---|---|
|[29](https://github.com/mojaloop/mojaloop-specification/issues/29)|Assigned|Use case choreographies|Reporting Processing Errors to the Payee DFSP|Reporting Processing Errors to the Payee DFSP - related to checking clearing result on the Payee side. This was discussed earlier as well|Submit proposal to the CCB; Talk to the design/dev team on Mojaloop about GET calls for clearing check|Henrik|2019/12/03|| ||
|[14](https://github.com/mojaloop/mojaloop-specification/issues/14)|Assigned||Identifying quote messages associated with Transfer messages|1. Follow GitHub issue #14<br>2. Discuss the issue</br><br>3. Canvass impact of this with Adrian in relation to Interledger</br>||Michael, CCB|2018/12/10||2019/06/11||
|[13](https://github.com/mojaloop/mojaloop-specification/issues/13)|Assigned||Changes for cross-network|Changes Proposed here:<br>https://github.com/mojaloop/cross-network/blob/master/part2-johannesburg-april-2019/api-changes.md</br><br>https://github.com/mojaloop/mojaloop-specification/issues/13</br>|Review, Feedback regarding the issues #13, #14 on GitHub by June 18th|CCB|2019/02/19||2019/07/09||
|9|Assigned||Case sensitivity/insensitivity issue of HTTP headers|The proposal is to have clarity by adding test to either API Definition or the Signature document or both to remove ambiguity regarding the case sensitivity of HTTP headers. Feedback on Solution Proposal by June 18th. Acceptance (if not blocking issues)||Henrik|2019/02/19||2019/07/09|
|[16](https://github.com/mojaloop/mojaloop-specification/issues/16)|Assigned||Clarity on whether or not padding is required while Base64URL Encoding|This change request is to make the requirement for padding in Base64URL encoding a) explicit in the API definition and the Signature document, and b) consistent between the two.<br>GitHub issue - https://github.com/mojaloop/mojaloop-specification/issues/16</br>|Solution Proposal, Feedback|Michael|2019/02/19||2019/07/09||
|[10](https://github.com/mojaloop/mojaloop-specification/issues/10)|Assigned||Tool for sequence diagrams|The team to make a decision on the tool to use for sequence diagrams (~75 of them). Michael proposed to use something like plantuml that is text based and is supported across formats and easy to distribute and upate|Feedback , Review on https://github.com/mojaloop/mojaloop-specification/issues/10, https://github.com/mojaloop/mojaloop-specification/pull/17|Michael, Sam|2019/02/19||2019/07/09||
|12|Assigned||Clarify usage of FSPIOP-Destination in GET /parties|So the change request would be two-folded:Correct Figure 5 in API Definition.<br>Update text in API Signature about only including FSPIOP-Destination when the Destination FSP is known.</br>|Solution Proposal|Henrik, Michael|2019/02/21||2019/07/09||
|13|Assigned||CCB Charter|Matt working internally regarding advice on the Draft CCB Charter; To share with the CCB team soon|Version 0.4 of the CCB Charter to be shared with team|Matt|2019/03/05||2019/07/09||
|14|Assigned||Proposal to use GitHub in an Open Forum for change requests, proposals etc|A proposal was made to use GitHub for CCB discussions regarding issues to avoid repetition at various forums and for visibility.|Continue Pilot process as the CCB Charter is being finalized|CCB|2019/03/19||2019/07/09||
|15|Assigned||Use Open API as the source for FSPIOP API Specification|Proposal to use the Open API version of the FSPIOP API Specification as the Source|Raise a Pull Request (PR)<br>Discuss the issue of 'precedence in case of conflict/discrepency'</br>|CCB, Sam, RJ|2019/03/19||2019/07/09||
|[15](https://github.com/mojaloop/mojaloop-specification/issues/15)|Assigned||Branding of Mojaloop. FSPIOP API. CCB Role|Clarity regarding the Mojaloop Branding - Is it just for the Open Source Switch implementaiton or the FSPIOP API?<br>GitHub Issue: https://github.com/mojaloop/mojaloop-specification/issues/15</br>	|Review, Feedback regarding the issue #15 on - https://github.com/mojaloop/mojaloop-specification/issues/15 |Matt|2019/04/23||2019/07/09||
|18|Assigned||Proposal for versioning document and resources separately|Henrik's proposal to maintain versions for the API Definition and resources separately|To have a separate discussion regarding moving to next version using the current (accepted) solution proposal|Henrik, Sam|2019/04/24||2019/07/09||
|19|Assigned||Proposal for extending error codes 4001, 5001 to bulk and quotes|Initial proposal|Solution Proposal updated|Henrik|2019/04/24||2019/06/11||

**Table 1** -- The table list all the **Assigned**/**Open** items.

## 4. Completed List
___

|Track Number|Status|Original Workstream|Title|Description|Next Steps|Responsible|Date Identified|Deadline|Date Updated|Date Resolved|
|---|---|---|---|---|---|---|---|---|---|---|
|1|Closed|Use case choreographies|API Signature issue|Resolve the API Signature issue in the specification|Decide on strategy - confirm or debate Henrik's proposal to allow identifying fields that should not be included in the Signature||13/02/2018||13/03/2018|2018/05/01|
|2|Closed|Use case choreographies|Cross-Implementation|Address the requirement for cross implementation|Submit proposal document to the CCB|Michael|2018/06/03||2018/12/19|2019/03/05|
|4|Closed|Use case choreographies|Duplicate ID in PUT calls|Dealing with duplicate PUT calls where an initial PUT request comes with one message and another with same ID but different message|To check API Definition to see if there is a section that already address this if not determine next steps to add it|Henrik, Michael|2018/05/15||2018/10/23|2018/11/30|
|5|Closed||Refund support|An implementer of the system has a need for the Refund Use Case, so a request was made to find out the implementation status from the TSP partners (if they are ready, tested and if they have any issues with the Specification)|Find out from other TSP patners, the status of implementation|CCB|2018/07/31||2018/09/11|2018/09/11|
|7|Closed||Template for a Change Request|Template for a Change Request - for proposing changes to the CCB regarding Mojaloop Specification|Pilot|Henrik|2019/01/08||2019/01/08|2019/03/19|
|17|Closed||Proposal about time-frame for adopting the changes accepted by the CCB|Discuss the issue of proposing a timeline on adopting/implementing the changes accepted and published by the CCB|Discussion among CCB team members|Matt, CCB|2019/04/23||2019/05/14|2019/05/14|

**Table 2** -- The table list all the **Deferred**/**Closed** items.
