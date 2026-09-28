# Dataset documentation for assemblykor package

#' assemblykor: Korean National Assembly Data for Political Science Education
#'
#' Provides ready-to-use datasets from the Korean National Assembly for
#' teaching quantitative methods in political science. Includes seven
#' built-in datasets covering legislator metadata, bills, asset
#' declarations, policy seminars, committee speeches, plenary vote
#' tallies, and member-level roll call votes.
#'
#' @section Built-in datasets:
#' \itemize{
#'   \item \code{\link{legislators}}: 948 MP records (20th-22nd assemblies)
#'   \item \code{\link{bills}}: 60,925 legislative bills
#'   \item \code{\link{wealth}}: 2,928 legislator-year asset declarations
#'   \item \code{\link{seminars}}: 5,962 legislator-year seminar records
#'   \item \code{\link{speeches}}: 15,795 speech records (22nd, Science & ICT Committee)
#'   \item \code{\link{votes}}: 8,050 plenary vote tallies (20th-22nd assemblies)
#'   \item \code{\link{roll_calls}}: 383,792 member-level roll call votes (22nd assembly)
#' }
#'
#' @section Download functions:
#' \itemize{
#'   \item \code{\link{get_bill_texts}}: 60,925 bill propose-reason texts
#'   \item \code{\link{get_proposers}}: 777,220 co-sponsorship records
#'   \item \code{\link{get_speech_tokens}}: 663,582 morpheme tokens for
#'     the \code{speeches} dataset (Kiwi morphological analyzer)
#' }
#'
#' @section Data corrections:
#' Version 0.1.4 corrects defects that release 0.7.0 of the kna project
#' (\url{https://github.com/kyusik-yang/kna}) found in the underlying Open
#' Assembly records, among them the seniority and committees of
#' \code{legislators}, the results of vetoed bills and the co-sponsorship
#' records cut at 100 names per bill. The coverage is unchanged, with data
#' as of March 2026. See the package NEWS for details.
#'
#' @section Tutorials:
#' Nine Korean-language tutorials covering tidyverse, visualization, regression,
#' panel data, text analysis, network analysis, roll call analysis, bill success,
#' and speech patterns. Use \code{\link{list_tutorials}} to see all tutorials,
#' and \code{\link{open_tutorial}} to copy them to your working directory.
#'
#' @docType package
#' @name assemblykor-package
"_PACKAGE"

#' Members of the Korean National Assembly (20th-22nd)
#'
#' Biographical and political metadata for 948 records of legislators who
#' served in the 20th (2016-2020), 21st (2020-2024), or 22nd (2024-2028)
#' Korean National Assembly. Some legislators appear in multiple assemblies.
#' The 22nd assembly covers the members seated by March 2026.
#'
#' @format A data frame with 948 rows and 15 variables:
#' \describe{
#'   \item{member_id}{Unique legislator identifier (MONA_CD from the National Assembly API)}
#'   \item{assembly}{Assembly number (20, 21, or 22)}
#'   \item{name}{Name in Korean (hangul)}
#'   \item{name_hanja}{Name in Chinese characters (hanja)}
#'   \item{name_eng}{Name in English (romanized)}
#'   \item{party}{Party label that the official roster of that assembly
#'     records for the member. It reflects party mergers, renamings and
#'     switches during the term. For the 22nd assembly it is the party as
#'     of March 2026.}
#'   \item{party_elected}{Party at election, that is, the party on whose ticket or
#'     list the member was elected. For a successor to a proportional
#'     seat, the party of the list the seat came from. The source records
#'     ten such successors under the party that the list party had merged
#'     into by the time they took the seat (for example, the Democratic
#'     Party of Korea for the Democratic Alliance of Korea), as does
#'     release 0.7.0 of the kna project.}
#'   \item{district}{Electoral district name, or party list position for proportional members}
#'   \item{district_type}{Election type: "constituency" or "proportional"}
#'   \item{committees}{Committees (standing and special) the member served
#'     on in that assembly, comma-separated in order of first assignment.
#'     Empty for a member with no assignment, such as the Speaker.}
#'   \item{gender}{"M" (male) or "F" (female)}
#'   \item{birth_date}{Date of birth}
#'   \item{seniority}{Seniority at that assembly, that is, the number of terms
#'     served up to and including this one, counting terms before the 20th
#'     (1 = first-term)}
#'   \item{n_bills}{Number of bills in \code{\link{bills}} the member
#'     proposed, co-proposed or supported (see \code{\link{get_proposers}})}
#'   \item{n_bills_lead}{Bills proposed as lead (primary) proposer}
#' }
#'
#' @details
#' 662 unique legislators served across the three assemblies. `member_id`
#' is consistent across assemblies, so legislators can be tracked over time.
#' Party names may differ between `party` (mid-term) and `party_elected`
#' (election day) due to party mergers and name changes, which are common
#' in Korean politics. Some legislators share a name with another member
#' of the same assembly (for example, two members named Kim Seong-tae in
#' the 20th), so join on `member_id`, never on `name`.
#'
#' Up to version 0.1.3, `seniority` held each member's lifetime number of
#' terms at the time of data collection, so it overstated the seniority of
#' 286 member-terms of the 20th and 21st assemblies, and `committees` came
#' from a present-day string that did not match the assembly. Both now
#' follow release 0.7.0 of the kna project, as do six values of
#' `party_elected`, one district, two district types and the bill counts.
#'
#' @source Open National Assembly Information API (Republic of Korea),
#'   as corrected in kna 0.7.0 (\url{https://github.com/kyusik-yang/kna}).
#'   License: public domain (Korean government open data).
#'
#' @examples
#' data(legislators)
#'
#' # Party composition by assembly
#' table(legislators$assembly, legislators$party)
#'
#' # Gender gap in bill production
#' tapply(legislators$n_bills_lead, legislators$gender, median)
#'
#' # First-term vs senior legislators
#' boxplot(n_bills_lead ~ seniority, data = legislators,
#'         xlab = "Terms served", ylab = "Bills proposed (lead)")
"legislators"


#' Bills Proposed in the Korean National Assembly (20th-22nd)
#'
#' Metadata for 60,925 legislative bills proposed during the 20th through
#' 22nd Korean National Assembly (2016-2026).
#'
#' @format A data frame with 60,925 rows and 11 variables:
#' \describe{
#'   \item{bill_id}{Unique bill identifier from the National Assembly system}
#'   \item{bill_no}{Numeric bill number}
#'   \item{assembly}{Assembly number (20, 21, or 22)}
#'   \item{bill_name}{Full bill title in Korean}
#'   \item{committee}{Standing committee to which the bill was referred}
#'   \item{propose_date}{Date the bill was formally proposed}
#'   \item{result}{Legislative outcome in Korean. Common values include
#'     passed as-is, expired at term end, and incorporated into
#'     alternative bill. \code{NA} for bills pending in March 2026. For a
#'     vetoed bill, the outcome after the veto (rejected on the re-vote,
#'     passed again, or expired at the end of the term). See
#'     \code{table(bills$result)} for all values.}
#'   \item{proposer}{Name of the lead (primary) proposer}
#'   \item{proposer_id}{MONA_CD of the lead proposer (links to
#'     \code{legislators$member_id}). Comma-separated for the few bills
#'     with joint lead proposers.}
#'   \item{vetoed}{Logical: the President returned the bill to the
#'     Assembly for reconsideration (a presidential veto)}
#'   \item{alt_vetoed}{Logical: the bill was incorporated into a committee
#'     alternative (\code{result} "incorporated into alternative bill")
#'     that was vetoed and not passed again, so its content never became
#'     law}
#' }
#'
#' @details
#' The Korean National Assembly has seen a dramatic increase in bill
#' proposals: the 21st Assembly produced 23,655 bills versus 21,594 in the
#' 20th. Most bills expire at the end of the assembly term
#' (term expiry). Only about 5\% are passed by the plenary, as proposed or
#' with amendments.
#'
#' Up to version 0.1.3, 11 of the 12 vetoed bills, which were rejected on
#' the re-vote or expired at the end of the term, kept the result of their
#' first floor vote. Their \code{result} now follows the re-vote, as in
#' release 0.7.0 of the kna project. To count bills whose content became
#' law, exclude \code{alt_vetoed} bills as well.
#'
#' Use \code{get_bill_texts()} to download the full propose-reason texts
#' for text analysis, and \code{get_proposers()} for the complete
#' co-sponsorship records (777,220 rows).
#'
#' @source Open National Assembly Information API (Republic of Korea),
#'   as corrected in kna 0.7.0 (\url{https://github.com/kyusik-yang/kna}).
#'
#' @examples
#' data(bills)
#'
#' # Bills per assembly
#' table(bills$assembly)
#'
#' # Top 10 committees
#' sort(table(bills$committee), decreasing = TRUE)[1:10]
#'
#' # Distribution of legislative outcomes
#' head(sort(table(bills$result), decreasing = TRUE))
"bills"


#' Legislator Asset Declarations (2015-2024)
#'
#' Panel data of asset declarations for 772 Korean National Assembly members
#' across 10 disclosure years (2015-2024). Derived from mandatory public
#' disclosures via the OpenWatch project.
#'
#' @format A data frame with 2,928 rows and 14 variables:
#' \describe{
#'   \item{member_id}{Legislator identifier (links to \code{legislators$member_id})}
#'   \item{year}{Disclosure year (2015-2024)}
#'   \item{name}{Legislator name in Korean}
#'   \item{total_assets}{Total declared assets, in thousands of KRW}
#'   \item{total_debt}{Total declared liabilities, in thousands of KRW}
#'   \item{net_worth}{Net worth (assets minus debt), in thousands of KRW}
#'   \item{real_estate}{Total real estate value, in thousands of KRW}
#'   \item{building}{Total building/structure value, in thousands of KRW}
#'   \item{land}{Total land value, in thousands of KRW}
#'   \item{deposits}{Total bank deposits, in thousands of KRW}
#'   \item{stocks}{Total stock holdings, in thousands of KRW}
#'   \item{n_properties}{Total number of properties disclosed}
#'   \item{has_seoul_property}{Logical: owns property in Seoul}
#'   \item{has_gangnam_property}{Logical: owns property in Gangnam (Seoul's wealthiest district)}
#' }
#'
#' @details
#' All monetary values are in thousands of KRW (1 unit = 1,000 won).
#' To convert to billions of won, divide by 1,000,000. For example,
#' a net_worth of 1,670,000 means 1.67 billion won (approximately
#' USD 1.2 million).
#'
#' Legislators are required by law to disclose their assets annually.
#' Not all legislators appear in every year, as the panel is unbalanced
#' (entries correspond to active service periods).
#'
#' @source OpenWatch (\url{https://docs.openwatch.kr/data/national-assembly}), CC BY-SA 4.0 license.
#'
#' @examples
#' data(wealth)
#'
#' # Distribution of net worth (in billions of won)
#' hist(wealth$net_worth / 1e6, breaks = 50,
#'      main = "Legislator Net Worth", xlab = "Billion KRW")
#'
#' # Real estate as share of total assets
#' wealth$re_share <- wealth$real_estate / wealth$total_assets
#' summary(wealth$re_share)
#'
#' # Gangnam property owners vs others
#' tapply(wealth$net_worth / 1e6, wealth$has_gangnam_property, median, na.rm = TRUE)
"wealth"


#' Policy Seminar Activity by Legislator-Year (2004-2025)
#'
#' Annual panel of policy seminar hosting activity for legislators in the
#' 17th through 22nd Korean National Assembly. Policy seminars (jeongchaek semina)
#' are informal legislative events where MPs invite experts, stakeholders,
#' and colleagues from other parties to discuss policy issues.
#'
#' @format A data frame with 5,962 rows and 18 variables:
#' \describe{
#'   \item{name}{Legislator name in Korean}
#'   \item{member_id}{Legislator identifier (MONA_CD, links to
#'     \code{legislators$member_id}). Available for 5,696 rows (95.5\%),
#'     and \code{NA} for unmatched or ambiguous (homonym) cases.}
#'   \item{year}{Calendar year}
#'   \item{assembly}{Assembly number (17-22), assigned from the calendar
#'     year (2004-2007 to the 17th, 2008-2011 to the 18th, and so on)}
#'   \item{party}{Party affiliation}
#'   \item{camp}{Political camp: "liberal", "conservative",
#'     "progressive", "centrist", or "other" (values are in Korean)}
#'   \item{seniority}{Seniority at that assembly, that is, the number of terms
#'     served up to and including this one, counting terms before the 17th
#'     (1 = first-term)}
#'   \item{n_seminars}{Number of policy seminars hosted that year}
#'   \item{n_cross_party}{Number of seminars co-hosted with other-party legislators}
#'   \item{cross_party_ratio}{Share of seminars that were cross-party (0-1)}
#'   \item{avg_coalition_size}{Average number of co-hosts per seminar}
#'   \item{is_governing}{Logical: belongs to the governing (presidential) party}
#'   \item{is_female}{Logical: female legislator}
#'   \item{is_proportional}{Logical: holds a proportional-representation
#'     seat in that assembly}
#'   \item{is_seoul}{Logical: represents a Seoul district in that assembly}
#'   \item{province}{Province or metropolitan city of the electoral district
#'     in that assembly, in Korean short form (e.g., Seoul, Gyeonggi).
#'     \code{NA} for proportional-representation members.}
#'   \item{total_terms}{Total assembly terms served across the career, as of
#'     September 2026}
#'   \item{n_bills_led}{Number of bills the legislator proposed as lead
#'     proposer in that assembly term (the same value in every year of the
#'     term)}
#' }
#'
#' @details
#' Policy seminars are a distinctive feature of the Korean National Assembly.
#' Unlike floor speeches or committee hearings, seminars are voluntary and
#' allow legislators to signal policy expertise and build cross-party ties.
#' The \code{cross_party_ratio} variable captures how often a legislator
#' cooperates across party lines in this informal arena.
#'
#' The \code{is_governing} variable enables difference-in-differences designs:
#' when a party transitions from opposition to governing (or vice versa),
#' does its members' cross-party collaboration change?
#'
#' The member attributes \code{seniority}, \code{total_terms},
#' \code{is_female}, \code{is_proportional}, \code{is_seoul} and
#' \code{province} come from the member records of release 0.7.0 of the
#' kna project, matched on \code{member_id} and \code{assembly}. Up to
#' version 0.1.3 they were matched on the name alone and counted only the
#' terms from the 17th assembly on. They are \code{NA} when a row has no
#' \code{member_id}, and all but \code{total_terms} and \code{is_female}
#' are \code{NA} when the legislator did not serve in that assembly.
#'
#' The panel counts seminars by name and year. Because a new assembly
#' begins on May 30 of an election year, the rows of an election year
#' also hold the activity of members of the outgoing assembly, under the
#' new assembly number. Legislators who share a name with another member
#' of the same assembly have one row per year for both of them, with
#' \code{member_id} \code{NA}.
#'
#' @source National Assembly Seminar Database, collected via API. Member
#'   attributes from kna 0.7.0 (\url{https://github.com/kyusik-yang/kna}).
#'
#' @examples
#' data(seminars)
#'
#' # Cross-party collaboration by governing status
#' tapply(seminars$cross_party_ratio, seminars$is_governing, mean, na.rm = TRUE)
#'
#' # Seminar activity over time
#' agg <- aggregate(n_seminars ~ year, data = seminars, FUN = sum)
#' plot(agg, type = "b", main = "Total Policy Seminars by Year")
#'
#' # Gender gap in seminar hosting
#' tapply(seminars$n_seminars, seminars$is_female, median, na.rm = TRUE)
"seminars"


#' Committee Speeches from the Science and ICT Committee (22nd Assembly)
#'
#' Full corpus of 15,795 speech records from the Science, Technology,
#' Information, Broadcasting and Communications Committee of the 22nd
#' Korean National Assembly (2024). Standing committee meetings only.
#'
#' @format A data frame with 15,795 rows and 10 variables:
#' \describe{
#'   \item{assembly}{Assembly number (22)}
#'   \item{date}{Date of the committee meeting}
#'   \item{committee}{Committee name in Korean}
#'   \item{speaker}{Speaker label as it appears in the minutes (may include
#'     titles)}
#'   \item{role}{Speaker role: "legislator", "chair", "minister",
#'     "vice_minister", "senior_bureaucrat", "agency_head", "witness",
#'     "expert_witness", "nominee", "minister_nominee", "testifier",
#'     "public_corp_head", "broadcasting", "committee_staff"}
#'   \item{speaker_name}{Cleaned speaker name with titles removed}
#'   \item{member_id}{Legislator identifier (MONA_CD, links to
#'     \code{legislators$member_id}) for the 12,060 speeches by members
#'     of the Assembly. \code{NA} for other speakers (ministers,
#'     witnesses, and the heads of other bodies).}
#'   \item{speaker_id}{Numeric speaker identifier used in the committee
#'     minutes, which versions up to 0.1.3 stored in \code{member_id}.
#'     \code{NA} for speakers who are not members of the Assembly.}
#'   \item{speech_order}{Order of the speech turn within the meeting}
#'   \item{speech}{Full text of the speech in Korean}
#' }
#'
#' @details
#' This dataset contains the complete standing committee speech records
#' (no sampling) for the Science and ICT Committee of the 22nd assembly
#' (June-December 2024). Speeches shorter than 50 characters were excluded.
#' \code{date} and \code{speech_order} identify a speech, except on
#' 2024-06-25, when two meetings were held and eight \code{speech_order}
#' values occur twice.
#'
#' Up to version 0.1.3, \code{member_id} held the numeric speaker
#' identifier of the minutes, so it did not link to
#' \code{legislators$member_id}, and 48 speeches of 2024-08-14 appeared
#' twice under two speaker identifiers. Version 0.1.4 attaches the MONA_CD
#' through the member records of release 0.7.0 of the kna project and
#' drops the duplicates.
#'
#' The \code{role} variable distinguishes legislators from government
#' officials, witnesses, and other participants. Filter to
#' \code{role == "legislator"} for MP speeches only, or compare how
#' legislators and ministers discuss the same agenda items.
#'
#' This committee covers AI, telecommunications, broadcasting, space
#' policy, and R&D governance, making it suitable for keyword analysis,
#' topic modeling, and other text analysis exercises.
#'
#' @source National Assembly committee minutes via the
#'   Open National Assembly Information API.
#'
#' @examples
#' data(speeches)
#'
#' # Distribution of speech lengths
#' hist(nchar(speeches$speech), breaks = 100,
#'      main = "Speech Length Distribution", xlab = "Characters")
#'
#' # Speaker roles
#' table(speeches$role)
#'
#' # Most frequent legislator speakers
#' leg <- speeches[speeches$role == "legislator", ]
#' head(sort(table(leg$speaker_name), decreasing = TRUE), 10)
#'
#' # Simple keyword search (example: AI-related speeches)
#' ai <- speeches[grepl("AI", speeches$speech), ]
#' nrow(ai)
"speeches"


#' Plenary Vote Results in the Korean National Assembly (20th-22nd)
#'
#' Bill-level vote tallies from plenary sessions of the 20th through
#' 22nd Korean National Assembly (2016-2026). Each row represents one
#' bill that went to a recorded floor vote.
#'
#' @format A data frame with 8,050 rows and 13 variables:
#' \describe{
#'   \item{bill_id}{Bill identifier (links to \code{bills$bill_id}).
#'     Unique except for bill 2000491 of the 20th assembly, which has two
#'     tally rows in the source.}
#'   \item{bill_no}{Numeric bill number}
#'   \item{bill_name}{Full bill title in Korean}
#'   \item{assembly}{Assembly number (20, 21, or 22)}
#'   \item{committee}{Standing committee to which the bill was referred}
#'   \item{vote_date}{Date of the plenary vote}
#'   \item{result}{Vote outcome in Korean (e.g., passed as-is,
#'     passed with amendments, rejected)}
#'   \item{bill_type}{Type of bill (e.g., legislation, budget, resolution)}
#'   \item{total_members}{Total number of assembly members at the time}
#'   \item{voted}{Number of members who cast a vote}
#'   \item{yes}{Number of yes votes}
#'   \item{no}{Number of no votes}
#'   \item{abstain}{Number of abstentions}
#' }
#'
#' @details
#' Not all bills go to a floor vote. Most bills are disposed of in
#' committee or expire at the end of the assembly term. The \code{votes}
#' dataset captures only those that reached the plenary floor for a
#' recorded vote.
#'
#' About 40\% of \code{votes$bill_id} match \code{bills$bill_id},
#' because \code{bills} only contains legislator-proposed bills while
#' \code{votes} also includes committee alternatives, budget bills,
#' and resolutions that have separate identifiers.
#'
#' See \code{\link{roll_calls}} for member-level voting records
#' (22nd assembly), useful for ideal point estimation or party
#' discipline analysis.
#'
#' @source Open National Assembly Information API (Republic of Korea),
#'   endpoint \code{ncocpgfiaoituanbr}.
#'
#' @examples
#' data(votes)
#'
#' # Votes per assembly
#' table(votes$assembly)
#'
#' # Pass rate
#' table(votes$result)
#'
#' # Average yes rate
#' votes$yes_rate <- votes$yes / votes$voted
#' summary(votes$yes_rate)
#'
#' # Contentious votes (yes rate < 70%)
#' contentious <- votes[votes$yes / votes$voted < 0.7, ]
#' nrow(contentious)
"votes"


#' Member-Level Roll Call Votes (22nd Assembly)
#'
#' Individual legislator voting records for all 1,286 bills that went
#' to a recorded plenary vote in the 22nd Korean National Assembly
#' from July 2024 to March 12, 2026. Each row represents one legislator's
#' vote on one bill.
#'
#' @format A data frame with 383,792 rows and 9 variables:
#' \describe{
#'   \item{bill_id}{Bill identifier (links to \code{votes$bill_id} and
#'     \code{bills$bill_id})}
#'   \item{assembly}{Assembly number (22)}
#'   \item{member_name}{Legislator name in Korean}
#'   \item{member_id}{Legislator identifier (MONA_CD, links to
#'     \code{legislators$member_id})}
#'   \item{party}{Party label reported by the API at data collection
#'     (March 2026). The API writes the member's party at that time onto
#'     every past vote, so a member who changed party during the term
#'     appears under the later party on all votes.}
#'   \item{party_elected}{Party at election, as in
#'     \code{legislators$party_elected}. Members elected on the lists of
#'     the satellite parties (e.g., the People Future Party and the
#'     Democratic Alliance of Korea) carry the list party, although they
#'     sat with other parties. Two members who succeeded to proportional
#'     seats during the term carry the Democratic Party of Korea, the
#'     party into which the Democratic Alliance of Korea had merged (see
#'     \code{\link{legislators}}).}
#'   \item{district}{Electoral district or proportional list position}
#'   \item{vote}{Vote cast in Korean: one of four values meaning
#'     yes, no, abstain, or absent}
#'   \item{vote_date}{Date of the vote}
#' }
#'
#' @details
#' This dataset covers the 22nd assembly. The same API endpoint also has
#' member-level votes of the 20th and 21st assemblies, which are left out
#' to keep the package small. Release 0.7.0 of the kna project
#' (\url{https://github.com/kyusik-yang/kna}) provides them. For the
#' 20th and 21st assemblies, use the bill-level \code{\link{votes}}
#' dataset.
#'
#' Neither party column records the party at the time of each vote. Up to
#' version 0.1.3, \code{party} was documented as the party at the time of
#' the vote. Version 0.1.4 corrects that description, adds
#' \code{party_elected}, and restores 53 votes cast on 2026-03-12 by a
#' member who had just taken up a vacant proportional seat, which the
#' March 2026 collection missed.
#'
#' This dataset enables ideal point estimation (e.g., W-NOMINATE),
#' party unity scores, and analysis of legislative coalitions. Use
#' \code{member_id} to link with \code{legislators} for biographical
#' metadata.
#'
#' @source Open National Assembly Information API (Republic of Korea),
#'   endpoint \code{nojepdqqaweusdfbi}, with the corrections of kna 0.7.0.
#'
#' @seealso \code{\link{votes}}
#'
#' @examples
#' data(roll_calls)
#'
#' # Vote distribution
#' table(roll_calls$vote)
#'
#' # Votes per party
#' head(sort(table(roll_calls$party), decreasing = TRUE))
#'
#' # Number of unique legislators
#' length(unique(roll_calls$member_id))
"roll_calls"


