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
#'   \item \code{\link{speeches}}: 7,500 committee speech excerpts (16th-20th)
#' }
#'
#' @section Download functions:
#' \itemize{
#'   \item \code{\link{get_bill_texts}}: 60,925 bill propose-reason texts
#'   \item \code{\link{get_proposers}}: 769,773 co-sponsorship records
#' }
#'
#' @section Tutorials:
#' Use \code{\link{list_tutorials}} to see available Korean-language tutorials,
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
#' @source Open National Assembly API (\url{https://open.assembly.go.kr}).
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
#'   \item{result}{Legislative outcome (e.g., "원안가결" = passed as-is,
#'     "임기만료폐기" = expired at term end, "대안반영폐기" = incorporated
#'     into alternative bill)}
#'   \item{proposer}{Name of the lead (primary) proposer}
#'   \item{proposer_id}{MONA_CD of the lead proposer (links to \code{legislators$member_id})}
#' }
#'
#' @details
#' The Korean National Assembly has seen a dramatic increase in bill
#' proposals: the 21st Assembly produced 23,655 bills versus 21,594 in the
#' 20th. Most bills expire at the end of the assembly term
#' ("임기만료폐기"); only about 5\% pass in their original form.
#'
#' Use \code{get_bill_texts()} to download the full propose-reason texts
#' for text analysis, and \code{get_proposers()} for the complete
#' co-sponsorship records (769,773 rows).
#'
#' @source Open National Assembly API (\url{https://open.assembly.go.kr}).
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
#' # Pass rate by assembly
#' tapply(bills$result == "원안가결", bills$assembly, mean, na.rm = TRUE)
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
#' @source OpenWatch (\url{https://openwatchdata.com}), CC BY-SA 4.0 license.
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
#' 16th through 22nd Korean National Assembly. Policy seminars (정책세미나)
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
#'   \item{camp}{Political camp: "민주계" (liberal), "보수계" (conservative),
#'     "진보계" (progressive), "기타" (other)}
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


#' Committee Speeches from the Korean National Assembly (16th-20th)
#'
#' A stratified random sample of 7,500 committee speech records from the
#' 16th through 20th Korean National Assembly (2000-2020). Speeches are
#' from standing committee meetings covering economic and infrastructure
#' policy areas.
#'
#' @format A data frame with 7,500 rows and 8 variables:
#' \describe{
#'   \item{assembly}{Assembly number (16-20)}
#'   \item{date}{Date of the committee meeting}
#'   \item{committee}{Standing committee name in Korean}
#'   \item{speaker}{Speaker label as it appears in the minutes (may include
#'     titles, e.g., "위원장 김영일" or "이원욱 위원")}
#'   \item{speaker_name}{Cleaned speaker name with titles removed.}
#'   \item{member_id}{Legislator identifier (MONA_CD, links to
#'     \code{legislators$member_id}). Available for ~54\% of speech rows.
#'     \code{NA} for government officials (장관, 차관, etc.), speakers
#'     from assemblies with sparse crosswalk data (especially 16th),
#'     or ambiguous homonym cases.}
#'   \item{speech_order}{Order of the speech turn within the meeting}
#'   \item{speech}{Full text of the speech in Korean}
#' }
#'
#' @details
#' This is a stratified sample of 1,500 speeches per assembly (16th-20th),
#' drawn from committee minutes. The committees covered
#' include finance and infrastructure-related standing committees
#' (기획재정위원회, 건설교통위원회, 국토교통위원회, etc.), which changed
#' names across assemblies due to government reorganizations.
#'
#' Speeches shorter than 50 characters were excluded from sampling.
#'
#' \strong{Linking to other datasets}: Use \code{member_id} to join with
#' \code{legislators}, \code{wealth}, \code{bills}, or \code{seminars}.
#' Where \code{member_id} is \code{NA}, \code{speaker_name} can be used
#' as a fallback for name-based joins.
#'
#' @source National Assembly committee minutes,
#'   published by the National Assembly of the Republic of Korea.
#'
#' @examples
#' data(speeches)
#'
#' # Speech count by assembly and committee
#' table(speeches$assembly, speeches$committee)
#'
#' # Distribution of speech lengths
#' hist(nchar(speeches$speech), breaks = 100,
#'      main = "Speech Length Distribution", xlab = "Characters")
#'
#' # Most frequent speakers
#' head(sort(table(speeches$speaker_name), decreasing = TRUE), 10)
#'
#' # Simple keyword search
#' housing <- speeches[grepl("부동산|주택", speeches$speech), ]
#' table(housing$assembly)
"speeches"
