﻿--DROP FUNCTION IF EXISTS de_metas_endcustomer_fresh_reports.Docs_Inout_Details_Footer( IN M_InOut_ID numeric, IN AD_Language Character Varying (6) );
CREATE OR REPLACE FUNCTION de_metas_endcustomer_fresh_reports.Docs_Inout_Details_Footer( IN M_InOut_ID numeric, IN AD_Language Character Varying (6) )

RETURNS TABLE
(
textleft text,
textcenter text,
language character varying,
m_inout_id numeric(10,0),
tag text,
pozition integer

)

AS
$$

SELECT
	*
FROM
	(
	--Docnote DE
	SELECT
		null			as textleft,
		CASE WHEN io.descriptionbottom IS NOT NULL
			THEN E'\n\n\n'
			ELSE ''
		END || dt.documentnote 	as textcenter,
		(SELECT AD_Language FROM AD_Language WHERE IsBaseLanguage = 'Y' AND isActive = 'Y') as language,
		io.m_inout_id		as m_inout_id,
		'docnote' 		as tag,
		3			as pozition
	FROM
		m_inout io
		LEFT JOIN c_doctype dt 		ON io.c_doctype_id 	= dt.c_doctype_id AND dt.isActive = 'Y'
	WHERE io.isActive = 'Y'
	UNION
---------------------------------------------------------------------------------------------
	--Docnote TRL
	SELECT
		null			as textleft,
		CASE WHEN io.descriptionbottom IS NOT NULL
			THEN E'\n\n\n'
			ELSE ''
		END || dt.documentnote	as textcenter,
		dt.ad_language		as language,
		io.m_inout_id		as m_inout_id,
		'docnote' 		as tag,
		3			as pozition
	FROM
		m_inout io
		LEFT JOIN c_doctype_trl dt 	ON io.c_doctype_id 	= dt.c_doctype_id AND dt.isActive = 'Y'
	WHERE io.isActive = 'Y'
	UNION
---------------------------------------------------------------------------------------------
	--Descriptionbottom
	SELECT
		io.descriptionbottom 	as textleft,
		null		 	as textcenter,
		null			as language,
		io.m_inout_id		as m_inout_id,
		'descr' 		as tag,
		2			as pozition
	FROM
		m_inout io
	WHERE io.isActive = 'Y'
	)footer
WHERE
	footer.m_inout_id = $1
	AND (footer.language = $2 OR footer.language IS NULL)
	AND (textleft <> '' OR textcenter <> '')
	AND (textleft IS NULL OR textcenter IS NULL)
ORDER BY
	pozition

$$
LANGUAGE sql STABLE;