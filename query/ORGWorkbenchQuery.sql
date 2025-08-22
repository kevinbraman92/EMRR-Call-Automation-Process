USE ChartFinder
SELECT DISTINCT

	om.outreachstatus											AS [Status],
	ISNULL(ps.OutreachId,'')									AS [OutreachID],
	ISNULL(om.primarysiteid,'')									AS [PrimarySiteID],
	ISNULL(om.OutreachTeam,'')									AS [OutreachTeam],
	ISNULL(au.FirstName + ' ' + au.LastName,' ')				AS [Agent],
    ISNULL(pi.ProjectId,'')										AS [ProjectId],
    ISNULL(lpt.Name,'')											AS [ProjectType],
	ISNULL(lot.Name,'')											AS [OutreachType],
	ISNULL(oct.SPOC,'')											AS [SPOC],
	ISNULL(sc.Name,'')											AS [Contact],
	ISNULL(CONVERT(VARCHAR(11), om.CallBackDate, 101),'')		AS [CallbackDate],
	ISNULL(om.CallBackTime,'')									AS [CallBackTime],
	(CASE WHEN ISNULL(sc.PhoneNum,'') <> '' 
		THEN (''+SUBSTRING(sc.PhoneNum, 1, 3) + '') + '-' +
			 SUBSTRING(sc.PhoneNum, 4, 3)  + '-' +
			 SUBSTRING(sc.PhoneNum, 7, 4)
		ELSE '' END)											AS [Phone],
	ISNULL(ps.LastNoteType,'')									AS [Result],
	ISNULL(CONVERT(VARCHAR(11), od.LastCallDate, 101), '')		AS [LastCall],
	ISNULL(CONVERT(VARCHAR(11), od.LastFaxDate, 101), '')		AS [LastFaxDate],
	ISNULL(oct.CallCount,0)										AS [TotalCallCount],
	ISNULL(oct.ClientCallCount,0)								AS [Client Call Count],
	ISNULL(oct.TotalCharts,0)									AS [TotalCharts],
	ISNULL(oct.RetrievedCharts,0)								AS [RetrievedCharts],
	ISNULL(oct.ToGoCharts,0)									AS [ToGoCharts],
	FORMAT((ROUND(oct.RetrievedCharts * 100 / 
			oct.TotalCharts, 2)/100),'P')						AS [Retrieval Percentage],
	ISNULL(NULL,'')												AS [** ScheduleStart],
	ISNULL(CONVERT(VARCHAR(11), om.ScheduleDate, 101), '')		AS [ScheduleDate],
	ISNULL(si.Address1,'')										AS [Address],
	ISNULL(si.Address2,'')										AS [Address2],   		
	ISNULL(si.City,'')											AS [City],
	ISNULL(si.State,'')											AS [State],
	ISNULL(si.ZIP,'')											AS [Zip],
	CASE WHEN om.PullListSent = 1 THEN 'Y' ELSE 'N' END			AS [PullList],
	CASE WHEN om.FormSite = 1 THEN 'Y' ELSE 'N' END				AS [FormSite],
	CASE WHEN om.StopRetrieval = 1 THEN 'Y' ELSE 'N' END		AS [StopRetrieval],
	ISNULL(CONVERT(VARCHAR(11), om.StopRetrievalDate, 101), '')	AS [StopRetrieval Date],
	ISNULL(opnp.Name,'')										AS [PNPCode],
	(CASE WHEN ISNULL(sc.FaxNum,'') <> '' 
	 THEN (''+SUBSTRING(sc.FaxNum, 1, 3) + '') + '-' +
			  SUBSTRING(sc.FaxNum, 4, 3) + '-' + 
			  SUBSTRING(sc.FaxNum, 7, 4)
		ELSE '' END)											AS [FaxNum],
	ISNULL(FORMAT(om.PullListSentDate,  'MM/dd/yyyy'),'')		AS [PullListSentDate],
	ISNULL(lorm.Name,'')										AS [RetrievalMethod],
	ISNULL(NULL,'Y')											AS [CanUseEMRDetail],
	ISNULL(NULL,'')												AS [CallCompleteDate],
	ISNULL(NULL,'')												AS [** TotalRecordCount],
	ISNULL(NULL,'')												AS [QRGDocPath],
	ISNULL(om.HealthPortSiteID,'')								AS [ROISiteId],
	ISNULL(cbu.ClientId,'')										AS [ClientId],
	ISNULL(NULL,'')												AS [** HPRetrievalMethod],
	ISNULL(NULL,'')												AS [** OnsiteRetrievalMethod],
	CONVERT(VARCHAR(11), p.DueDate, 101)						AS [Project Due Date],
	ISNULL(hrdo.rdo,'')											AS [RDO],
	ISNULL(hrdo.vpo,'')											AS [VPO],
	ISNULL(hrdo.rmo,'')											AS [RMO],
	ISNULL(hrdo.smp,'')											AS [SMP],
	ISNULL(NULLIF(oct.OpenROISHCodes,'0'),'')					AS [ROISHCodes],
	ISNULL(NULL,'')												AS [ROISHCodeOpen],
	CASE WHEN om.DeliveryStatus = 2 THEN 'Sent' ELSE '' END		AS [DeliveryStatus],
	ISNULL(ps.DeliveryCount,'')									AS [DeliveryCount],
	ISNULL(ps.EMRSystem,'')										AS [EMRSystem],
	ISNULL(NULL,'')												AS [** EMRSiteId],
	ISNULL(om.HIHSiteId,'')										AS [HIHSiteId],
	ISNULL(om.HIHVendorId,'')									AS [HIHVendorId],
	CASE WHEN om.ClientReview = 1 THEN 'Yes' ELSE 'No' END		AS [ClientReview],
	cast(p.ChartReviewYear as varchar(10))						AS [ProjectYear],
	ISNULL(stm.Region,'')										AS [Market],
	ISNULL(stm.BigRegion,'')									AS [Region],
	ISNULL(sts.FirstName + ' ' + sts.LastName,'')				AS [RegionalSupervisor], 
	ISNULL(AuditTypes.AuditType,'')								AS [Audit Type],
	ISNULL(p.Wave,'')											AS [Wave],
	ISNULL(NULL,'')												AS [EMRStatus],
	ISNULL(lrtt.Name,'')										AS [RetrievalTeam],
	ISNULL(scl.SiteCleanID,'')									AS [SiteCleanID],
	ISNULL(DATEDIFF(Day, om.InsertDate, 
			CONVERT(VARCHAR(10),GETDATE(),101)) -
			(DATEDIFF(wk, om.InsertDate, 
			CONVERT(VARCHAR(10),GETDATE(),101)) ),'')			AS [DaysSinceCreation],
	ISNULL(omsi.name,'')										AS [Master Site],
	ISNULL(omsid.MSId,'')										AS [MasterSiteID]


FROM
	Chart										AS c		WITH (NOLOCK) 
	LEFT JOIN ChartProvider						AS cp		WITH (NOLOCK) 	ON  cp.chartid = c.chartid
	LEFT JOIN ChartPaymentAgreement				AS cpa		WITH (NOLOCK) 	ON  cpa.ChartId = c.ChartId
	LEFT JOIN ChartROI							AS croi		WITH (NOLOCK) 	ON  croi.chartid = c.chartid
	LEFT JOIN ChartEMR							AS cemr		WITH (NOLOCK) 	ON  cemr.chartid = c.chartid
	LEFT JOIN Chartprep							AS cprp		WITH (NOLOCK) 	ON  cprp.chartid = c.chartid
	LEFT JOIN ChartNotes						AS cn		WITH (NOLOCK) 	ON  cn.ChartId = c.ChartId
	LEFT JOIN ChartSupplementalFiles			AS csf		WITH (NOLOCK) 	ON  csf.ChartId = c.ChartId			
	LEFT JOIN DWWorking.Prod.Master_Reporting_Table	AS mt	WITH (NOLOCK) 	ON  mt.ChartId = c.ChartId

	LEFT JOIN Project 							AS p		WITH (NOLOCK)	ON p.ProjectId = c.ProjectId
	LEFT JOIN Projectsite 						AS ps		WITH (NOLOCK)	ON ps.ProjectId = c.ProjectId				
																				AND ps.SiteId = c.SiteId
	LEFT JOIN ProjectImport 					AS pi		WITH (NOLOCK)	ON pi.ChartId = c.ChartId 
	
	LEFT JOIN (SELECT
				[Name]	AS AuditType,
				[value]	AS AuditTypeID
				FROM List WITH (NOLOCK)
				WHERE ListType = 'AuditType')	AS AuditTypes				ON p.AuditType = AuditTypes.AuditTypeID
	LEFT JOIN OutreachMaster					AS om		WITH (NOLOCK)	ON om.OutreachId = ps.OutreachId			
	LEFT JOIN OutreachDates						AS od		WITH (NOLOCK)	ON od.OutreachId = ps.OutreachId
	LEFT JOIN OutreachCall						AS ocl 		WITH (NOLOCK)	ON ocl.OutreachId = ps.OutreachId
	LEFT JOIN OutreachCount						AS oct		WITH (NOLOCK)	ON oct.OutreachId = ps.OutreachId
	LEFT JOIN OutreachStatus					AS os		WITH (NOLOCK)	ON os.OutreachId = ps.OutreachId
	LEFT JOIN OutreachBU						AS obu		WITH (NOLOCK)	ON obu.OutreachId = ps.OutreachId
	LEFT JOIN OutreachMSId						AS omsid	WITH (NOLOCK)	ON omsid.OutreachId = ps.OutreachId
	LEFT JOIN MasterSiteId.dbo.MSI				AS omsi		WITH (nolock)	ON omsi.Id = omsid.MSId
	LEFT JOIN OutreachSpecialHandling			AS osh		WITH (NOLOCK)	ON osh.OutreachId = ps.OutreachId
	LEFT JOIN OutreachPNPLog					AS opl		WITH (NOLOCK)	ON opl.OutreachId = ps.OutreachId
	LEFT JOIN OutreachScheduleDateLog			AS osd		WITH (NOLOCK)	ON osd.OutreachId = ps.OutreachId
	LEFT JOIN OutreachEMRDetailForm				AS oef		WITH (NOLOCK)	ON oef.OutreachId = ps.OutreachId
	LEFT JOIN ChartFinder.dbo.OutreachOptum		AS oo		WITH (NOLOCK)	ON om.outreachid = oo.outreachid
	LEFT JOIN ChartFinder.dbo.AppUser			AS au		WITH (NOLOCK)	ON au.Id = oo.Agent

	LEFT JOIN ProjectSite						AS psr		WITH (nolock)	ON psr.ProjectId = c.ProjectId 
																				AND psr.SiteId = om.primarysiteid 
																				AND psr.outreachid = om.outreachid

	JOIN site									AS si		WITH (NOLOCK)	ON si.id = psr.Siteid
	JOIN SiteContact							AS sc		WITH (NOLOCK) 	ON sc.Id = psr.PrimaryContactId
																				AND sc.SiteId = psr.SiteId  
																				AND sc.PrimaryFlag = 1
	LEFT JOIN SiteClean 						AS scl		WITH (NOLOCK)	ON scl.SiteCleanId = si.SiteCleanId
	LEFT JOIN HealthPort_RDO					AS hrdo		WITH (NOLOCK)	ON hrdo.SiteId = om.primarysiteid
	LEFT JOIN StateMaster						AS stm		WITH (NOLOCK)	ON stm.zip = si.zip
	
	LEFT JOIN ClientBusinessUnit				AS cbu		WITH (NOLOCK)	ON cbu.BusinessUnitId = obu.BusinessUnitId
 	LEFT JOIN [DW_Operations].[dbo].[DimClient]	AS cl		WITH (NOLOCK)	ON cl.clientId = pi.clientId
	LEFT JOIN ChartBULOB						AS clb		WITH (NOLOCK)	ON clb.chartid = c.chartid
	
	LEFT JOIN MasterNotes						AS mn		WITH (NOLOCK)	ON mn.OutreachId = ps.outreachid
	LEFT JOIN MasterNotesArchive				AS mna		WITH (NOLOCK)	ON mna.OutreachId = ps.outreachid
	
	LEFT JOIN [DW_Operations]..[DimOutreach]	AS do		WITH (NOLOCK)	ON do.outreachid = om.outreachid
	LEFT JOIN [DW_Operations]..[DimloginName]	AS lgnca	WITH (NOLOCK)	ON lgnca.loginnameid = om.CallAgent
	LEFT JOIN [DWWorking]..[API_Ultipro_Levels]	AS ultiuid	WITH (NOLOCK)	ON ultiuid.EmailAddress = lgnca.Email

	LEFT JOIN [DW_Operations]..[DimloginName]	AS sba		WITH (NOLOCK)	ON sba.loginnameid = osd.ScheduledById
	LEFT JOIN [DW_Operations]..[DimReviewType]	AS lrwt		WITH (NOLOCK)	ON lrwt.ReviewTypeID = pi.ReviewType
	LEFT JOIN [DWWorking]..[API_Ultipro_Levels]	AS ulti		WITH (NOLOCK)	ON ulti.EmailAddress = lgnca.email
	LEFT JOIN [DWWorking]..[OutreachData]		AS odt		WITH (NOLOCK)	ON odt.outreachid = ps.outreachid
	LEFT JOIN [DW_Operations]..[DimloginName]	AS cpnpr	WITH (NOLOCK)	ON cpnpr.loginnameid = c.PNPReleasedById
	LEFT JOIN [DW_Operations]..[DimloginName]	AS cib		WITH (NOLOCK)	ON cib.loginnameid = c.IndexedBy
	LEFT JOIN [DW_Operations]..[DimloginName]	AS cprb		WITH (NOLOCK)	ON cprb.loginnameid = cprp.PrepORBy
	LEFT JOIN [DW_Operations]..[DimloginName]	AS sts		WITH (NOLOCK)	ON sts.loginnameid = stm.Supervisor
	LEFT JOIN [DW_Operations]..[DimReviewType]	AS lrt		WITH (NOLOCK)	ON lrt.ReviewTypeID = pi.ReviewType



	LEFT JOIN List		AS lrtt		WITH (NOLOCK)	ON om.RetrievalTeam = lrtt.Value		AND lrtt.ListType = 'RetrievalTeam'
	LEFT JOIN List		AS opnp		WITH (NOLOCK)	ON om.PNPCode = opnp.value 	 			AND opnp.ListType = 'PNPCode'
	LEFT JOIN List		AS cpnp		WITH (NOLOCK)	ON c.PNPCode = cpnp.value				AND cpnp.ListType = 'PNPCode'
	LEFT JOIN List		AS lcrm		WITH (NOLOCK)	ON c.RetrievalMethod = lcrm.Value		AND lcrm.ListType = 'RetrievalMethod'
	LEFT JOIN List		AS lorm		WITH (NOLOCK)	ON om.RetrievalMethod = lorm.Value		AND lorm.ListType = 'RetrievalMethod'
	LEFT JOIN List		AS lps		WITH (NOLOCK)	ON p.Status = lps.Value 				AND lps.ListType =  'ProjectStatus'
	LEFT JOIN List 		AS lpss		WITH (NOLOCK)	ON ps.Status = lpss.Value 				AND lpss.ListType = 'ProjectSiteStatus' 
	LEFT JOIN List		AS lcs		WITH (NOLOCK)	ON c.[Status] = lcs.Value				AND lcs.ListType =  'ChartStatus'
	LEFT JOIN List		AS lst		WITH (NOLOCK)	ON ps.SiteType = lst.value				AND lst.listtype =  'SiteType'
	LEFT JOIN List		AS lot		WITH (NOLOCK)	ON om.outreachtype = lot.value			AND lot.listtype =  'OutreachType'
	LEFT JOIN List		AS lat		WITH (NOLOCK)	ON p.AuditType = lat.value				AND lat.listtype =  'AuditType'
	LEFT JOIN List		AS lpt		WITH (NOLOCK)	ON p.ProjectType = lpt.Value			AND lpt.ListType =  'ProjectType'
	LEFT JOIN List		AS lnt		WITH (NOLOCK)	ON mn.NoteType = lnt.Value 				AND lnt.ListType =  'NotesType' 
	LEFT JOIN List		AS lcc		WITH (NOLOCK)	ON c.CancelledCode = lcc.Value 			AND lcc.ListType =  'CancelledCode' 
	LEFT JOIN List		AS lpp		WITH (NOLOCK)	ON ps.ProviderParticipating = lpp.Value AND lpp.ListType =  'ProviderParticipating'
	LEFT JOIN List		AS lemr		WITH (NOLOCK)	ON cemr.EMRId = lemr.Value 				AND lemr.ListType = 'EMRSystem'
	LEFT JOIN List		AS lprp		WITH (NOLOCK)	ON cprp.PrepORStatus = lprp.Value 		AND lprp.ListType = 'PrepORStatus'


WHERE
	p.[Status] = 3
	AND lorm.Name IN ('EMR - Remote', 'EMR - Remote Queued')
	AND om.OutreachStatus IN ('Unscheduled', 'PNP Released', 'Escalated', 'Escalated/Past Due', 'Acct Mgmt Research')
	


