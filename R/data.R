# Dataset documentation for assemblykor package

#' assemblykor: Korean National Assembly Data for Political Science Education
#'
#' Provides ready-to-use datasets from the Korean National Assembly for
#' teaching quantitative methods in political science. Includes five
#' built-in datasets covering legislator metadata, bills, asset
#' declarations, policy seminars, and committee speeches.
#'
#' @section Built-in datasets:
#' \itemize{
#'   \item \code{\link{legislators}}: 947 MP records (20th-22nd assemblies)
#'   \item \code{\link{bills}}: 60,925 legislative bills
#'   \item \code{\link{wealth}}: 2,928 legislator-year asset declarations
#'   \item \code{\link{seminars}}: 5,962 legislator-year seminar records
#'   \item \code{\link{speeches}}: 15,843 speech records (22nd, Science & ICT Committee)
#'   \item \code{\link{votes}}: 7,997 plenary vote tallies (20th-22nd assemblies)
#'   \item \code{\link{roll_calls}}: 368,210 member-level roll call votes (22nd assembly)
#' }
#'
#' @section Download functions:
#' \itemize{
#'   \item \code{\link{get_bill_texts}}: 60,925 bill propose-reason texts
#'   \item \code{\link{get_proposers}}: 769,773 co-sponsorship records
#' }
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
#' Biographical and political metadata for 947 records of legislators who
#' served in the 20th (2016-2020), 21st (2020-2024), or 22nd (2024-2028)
#' Korean National Assembly. Some legislators appear in multiple assemblies.
#'
#' @format A data frame with 947 rows and 15 variables:
#' \describe{
#'   \item{member_id}{Unique legislator identifier (MONA_CD from the National Assembly API)}
#'   \item{assembly}{Assembly number (20, 21, or 22)}
#'   \item{name}{Name in Korean (hangul)}
#'   \item{name_hanja}{Name in Chinese characters (hanja)}
#'   \item{name_eng}{Name in English (romanized)}
#'   \item{party}{Party affiliation during the assembly term}
#'   \item{party_elected}{Party at the time of election}
#'   \item{district}{Electoral district name, or party list position for proportional members}
#'   \item{district_type}{Election type: "constituency" or "proportional"}
#'   \item{committees}{Standing committee assignments (comma-separated)}
#'   \item{gender}{"M" (male) or "F" (female)}
#'   \item{birth_date}{Date of birth}
#'   \item{seniority}{Number of terms served, including current (1 = first-term)}
#'   \item{n_bills}{Total bills participated in (as lead proposer or co-sponsor)}
#'   \item{n_bills_lead}{Bills proposed as lead (primary) proposer}
#' }
#'
#' @details
#' 661 unique legislators served across the three assemblies. `member_id`
#' is consistent across assemblies, so legislators can be tracked over time.
#' Party names may differ between `party` (mid-term) and `party_elected`
#' (election day) due to party mergers and name changes, which are common
#' in Korean politics.
#'
#' @source Open National Assembly Information API (Republic of Korea).
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
#' @format A data frame with 60,925 rows and 9 variables:
#' \describe{
#'   \item{bill_id}{Unique bill identifier from the National Assembly system}
#'   \item{bill_no}{Numeric bill number}
#'   \item{assembly}{Assembly number (20, 21, or 22)}
#'   \item{bill_name}{Full bill title in Korean}
#'   \item{committee}{Standing committee to which the bill was referred}
#'   \item{propose_date}{Date the bill was formally proposed}
#'   \item{result}{Legislative outcome in Korean. Common values include
#'     passed as-is, expired at term end, and incorporated into
#'     alternative bill. See \code{table(bills$result)} for all values.}
#'   \item{proposer}{Name of the lead (primary) proposer}
#'   \item{proposer_id}{MONA_CD of the lead proposer (links to \code{legislators$member_id})}
#' }
#'
#' @details
#' The Korean National Assembly has seen a dramatic increase in bill
#' proposals: the 21st Assembly produced 23,655 bills versus 21,594 in the
#' 20th. Most bills expire at the end of the assembly term
#' (term expiry); only about 5\% pass in their original form.
#'
#' Use \code{get_bill_texts()} to download the full propose-reason texts
#' for text analysis, and \code{get_proposers()} for the complete
#' co-sponsorship records (769,773 rows).
#'
#' @source Open National Assembly Information API (Republic of Korea).
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


#' Legislator Asset Declarations (2015-2025)
#'
#' Panel data of asset declarations for 773 Korean National Assembly members
#' across 13 reporting periods (2015-2025). Derived from mandatory public
#' disclosures via the OpenWatch project.
#'
#' @format A data frame with 2,928 rows and 14 variables:
#' \describe{
#'   \item{member_id}{Legislator identifier (links to \code{legislators$member_id})}
#'   \item{year}{Disclosure year (2015-2025)}
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


#' Policy Seminar Activity by Legislator-Year (2000-2025)
#'
#' Annual panel of policy seminar hosting activity for legislators in the
#' 16th through 22nd Korean National Assembly. Policy seminars (jeongchaek semina)
#' are informal legislative events where MPs invite experts, stakeholders,
#' and colleagues from other parties to discuss policy issues.
#'
#' @format A data frame with 5,962 rows and 18 variables:
#' \describe{
#'   \item{name}{Legislator name in Korean}
#'   \item{member_id}{Legislator identifier (MONA_CD, links to
#'     \code{legislators$member_id}). Available for ~95\% of rows;
#'     \code{NA} for unmatched or ambiguous (homonym) cases.}
#'   \item{year}{Calendar year}
#'   \item{assembly}{Assembly number (17-22)}
#'   \item{party}{Party affiliation}
#'   \item{camp}{Political camp: "liberal", "conservative",
#'     "progressive", or "other" (values are in Korean)}
#'   \item{seniority}{Number of terms served}
#'   \item{n_seminars}{Number of policy seminars hosted that year}
#'   \item{n_cross_party}{Number of seminars co-hosted with other-party legislators}
#'   \item{cross_party_ratio}{Share of seminars that were cross-party (0-1)}
#'   \item{avg_coalition_size}{Average number of co-hosts per seminar}
#'   \item{is_governing}{Logical: belongs to the governing (presidential) party}
#'   \item{is_female}{Logical: female legislator}
#'   \item{is_proportional}{Logical: proportional-representation member}
#'   \item{is_seoul}{Logical: represents a Seoul district}
#'   \item{province}{Province/metro area of electoral district}
#'   \item{total_terms}{Total assembly terms served across career}
#'   \item{n_bills_led}{Number of bills proposed as lead proposer that year}
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
#' @source National Assembly Seminar Database, collected via API.
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
#' Full corpus of 15,843 speech records from the Science, Technology,
#' Information, Broadcasting and Communications Committee of the 22nd
#' Korean National Assembly (2024). Standing committee meetings only.
#'
#' @format A data frame with 15,843 rows and 9 variables:
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
#'     \code{legislators$member_id}). Available for all rows; however,
#'     non-legislator speakers (ministers, witnesses, etc.) will not match
#'     entries in \code{legislators}.}
#'   \item{speech_order}{Order of the speech turn within the meeting}
#'   \item{speech}{Full text of the speech in Korean}
#' }
#'
#' @details
#' This dataset contains the complete standing committee speech records
#' (no sampling) for the Science and ICT Committee of the 22nd assembly
#' (June-December 2024). Speeches shorter than 50 characters were excluded.
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
#' @format A data frame with 7,997 rows and 13 variables:
#' \describe{
#'   \item{bill_id}{Unique bill identifier (links to \code{bills$bill_id})}
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
#' Individual legislator voting records for all 1,233 bills that went
#' to a recorded plenary vote in the 22nd Korean National Assembly
#' (2024-2026). Each row represents one legislator's vote on one bill.
#'
#' @format A data frame with 368,210 rows and 8 variables:
#' \describe{
#'   \item{bill_id}{Bill identifier (links to \code{votes$bill_id} and
#'     \code{bills$bill_id})}
#'   \item{assembly}{Assembly number (22)}
#'   \item{member_name}{Legislator name in Korean}
#'   \item{member_id}{Legislator identifier (MONA_CD, links to
#'     \code{legislators$member_id})}
#'   \item{party}{Party affiliation at time of vote}
#'   \item{district}{Electoral district or proportional list position}
#'   \item{vote}{Vote cast in Korean: one of four values meaning
#'     yes, no, abstain, or absent}
#'   \item{vote_date}{Date of the vote}
#' }
#'
#' @details
#' The member-level roll call API is only available for the 22nd
#' assembly. For the 20th and 21st assemblies, use the bill-level
#' \code{\link{votes}} dataset.
#'
#' This dataset enables ideal point estimation (e.g., W-NOMINATE),
#' party unity scores, and analysis of legislative coalitions. Use
#' \code{member_id} to link with \code{legislators} for biographical
#' metadata.
#'
#' @source Open National Assembly Information API (Republic of Korea),
#'   endpoint \code{nojepdqqaweusdfbi}.
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


