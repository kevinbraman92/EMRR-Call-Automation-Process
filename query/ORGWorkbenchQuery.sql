Select 

 ps.OutreachId AS 'OutreachID',
    CASE 
        WHEN om.OutreachStatus = 'Scheduled' AND CAST(om.ScheduleDate AS DATE) < CAST(GETDATE() AS DATE) 
            THEN 'Past Due'
        ELSE om.OutreachStatus
    END AS 'Outreach status',
om.PrimarySiteId,
om.OutreachTeam,
CONCAT(lgnca.FirstName, ' ', lgnca.LastName) AS 'Agent',
c.ProjectId AS 'ProjectID',
pt.Name AS 'ProjectType',
ISNULL(om.OutreachType, '') AS 'OutreachType',
oct.SPOC AS 'SPOC',
i.ProviderGroupName AS 'Contact',
ISNULL(om.CallBackDate, '') AS 'CallbackDate',
ISNULL(om.CallBackTime, '')  AS 'CallBackTime',
sc.PhoneNum AS 'Phone',
od.LastCallDate,
od.LastFaxDate,
oct.CallCount AS 'TotalCallCount',
oct.TotalCharts,
oct.RetrievedCharts,
oct.ToGoCharts,
(oct.RetrievedCharts / oct.TotalCharts) * 100 AS 'RetrievedPercent',
om.ScheduleDate,
si.Address1 AS 'Adress',
si.Address2 AS 'Address2',
si.City AS 'City',
si.State AS 'State',
si.ZIP AS 'Zip',
psr.ScheduledOnDate,
p.DueDate,
ISNULL(pnp.Name,'') AS 'PNPCode',
om.PullListSentBy,
om.PullListSentDate,
mt.RetrievalTeam,
orm.name AS 'RetrievalMethod',
a.name AS 'AuditType', 
ISNULL(pis.Market, '') AS 'Market',
ISNULL(mt.Region,'') AS 'Region',
p.ChartReviewYear AS 'Project Year',
si.SiteCleanId,
ISNULL(hp.RDO, '') AS 'RDO',
ISNULL(hp.VPO, '') AS 'VPO',
ISNULL(hp.SMP, '') AS 'SMP',
ISNULL(oct.OpenROISHCodes, '') AS 'Open ROI SH Codes',
ISNULL(oct.SHCodesCount, '') AS 'SH Codes Count',
p.Wave




FROM
Chart c
LEFT JOIN ProjectSite ps ON c.ProjectId = ps.ProjectId and c.SiteId = ps.SiteId
LEFT JOIN OutreachMaster om ON ps.OutreachId = om.OutreachId
JOIN ProjectImport i ON c.ChartId = i.ChartId
JOIN Project p ON c.ProjectId = p.ProjectId
left JOIN ClientDetails cl ON i.ClientId = cl.ClientId
LEFT JOIN CustomPullListData cp ON i.BarcodeId = cp.ClientChartId
LEFT JOIN ClientBusinessUnit cbu ON i.BusinessUnitId = cbu.BusinessUnitId AND i.ClientId = cbu.ClientId
JOIN List pt ON p.ProjectType = pt.Value AND pt.ListType = 'ProjectType'
JOIN List cs ON c.Status = cs.Value AND cs.ListType = 'ChartStatus'
LEFT JOIN List st ON ps.SiteType = st.Value AND st.ListType = 'SiteType'
LEFT JOIN List rm ON c.RetrievalMethod = rm.Value AND rm.ListType = 'RetrievalMethod'
LEFT JOIN List orm ON om.RetrievalMethod = orm.Value AND orm.ListType = 'RetrievalMethod'
LEFT JOIN List cna ON c.CNACode = cna.Value AND cna.ListType = 'CNACode'
LEFT JOIN List pnp ON c.PNPCode = pnp.Value AND pnp.ListType = 'PNPCode'
LEFT JOIN List clc ON c.CancelledCode = clc.Value AND clc.ListType = 'CancelledCode'
LEFT JOIN ChartEMR ce ON c.ChartId = ce.ChartId
LEFT JOIN List emr ON ce.EMRId = emr.Value and emr.ListType = 'EMRSystem'
LEFT JOIN List emr ON om.EMRSystem = emr.Value and emr.ListType = 'EMRSystem'
LEFT JOIN ProjectImport_Supplemental pis ON i.ChartId = pis.ChartId
LEFT JOIN AppUser aur ON c.RetrievedById = aur.Id
LEFT JOIN AppUser acna ON c.CNAById = acna.Id
LEFT JOIN AppUser apnp ON c.PNPById = apnp.Id
LEFT JOIN AppUser apnpc ON c.PNPClosedById = apnpc.Id
LEFT JOIN AppUser acnl ON c.CancelledById = acnl.Id
LEFT JOIN AppUser apnpr ON c.PNPReleasedById = apnpr.Id
LEFT JOIN AppUser ar ON c.ReleasedById = ar.Id
  LEFT JOIN Healthport_RDO hr ON om.HealthPortSiteId = cast(hr.SiteId as varchar(50))
LEFT JOIN HealthPort_Intake h ON c.ChartId = h.ChartId
LEFT JOIN List a ON p.AuditType = a.Value AND a.ListType = 'AuditType'
LEFT JOIN OutreachCount AS oct ON oct.OutreachId = ps.OutreachId
LEFT JOIN OutreachDates						AS od			ON od.OutreachId = ps.OutreachId
LEFT JOIN [DW_Operations]..[DimloginName]	AS lgnca		ON lgnca.loginnameid = om.CallAgent
LEFT JOIN HealthPort_RDO hp ON om.HealthPortSiteID = CAST(hp.SiteId AS VARCHAR)
LEFT JOIN DWWorking.Prod.Master_Reporting_Table	AS mt ON c.ChartId = mt.ChartId
JOIN ProjectSite							AS psr			ON psr.ProjectId = c.ProjectId 
																		AND psr.SiteId = om.primarysiteid 
																		AND psr.outreachid = om.outreachid
	JOIN site									AS si			ON si.id = psr.Siteid
	JOIN SiteContact							AS sc			ON sc.Id = psr.PrimaryContactId
																		AND sc.SiteId = psr.SiteId  
																		AND sc.PrimaryFlag = 1

WHERE 
	om.OutreachStatus IN ('Unscheduled', 'PNP Released', 'Escalated')
	AND rm.Name IN ('EMR - Remote', 'EMR - Remote Queued') 


