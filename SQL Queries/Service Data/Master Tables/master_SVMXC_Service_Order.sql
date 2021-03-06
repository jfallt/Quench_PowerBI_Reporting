/*
Find missing work orders without products and put them in a temporary table

DROP TABLE IF EXISTS #WO_WITHOUT_PRODUCTS

CREATE TABLE #WO_WITHOUT_PRODUCTS
	(
		id VARCHAR(100),
		SVMXC__Product__c VARCHAR(100)
	)

INSERT INTO #WO_WITHOUT_PRODUCTS
SELECT DISTINCT so.id
	,sip.SVMXC__Product__c
FROM Temporal.SVMXCServiceOrder so
LEFT JOIN Temporal.SVMXCInstalledProduct sip on sip.Q_Number__c = so.Scanned_Q_Number__c
WHERE so.SVMXC__Product__c IS NULL
AND SVMXC__Order_Status__c = 'Complete'
AND sip.SVMXC__Status__c = 'Installed'
*/

/*
Work order query
*/

SELECT s.Id
	,s.[Name] as 'WorkOrder'
	,DATEPART(Hour, (s.CreatedDate AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time')) as 'CreatedDate (Hour)'
	,CAST((s.CreatedDate AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') as DATE) as 'CreatedDate (Date Only)'
	,ISNULL(s.SVMXC__Actual_Resolution__c AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'
		,s.SVMXC__Closed_On__c AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time')  as 'Actual Resolution' -- work order completion
	,SVMXC__Scheduled_Date_Time__c  AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' as 'Scheduled Date'
	,CASE
		WHEN SVMXC__Order_Type__c IN ('PM', 'Routine') --consolidate due dates into one column based on order type
		THEN SVMXC__Preferred_Start_Time__c AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'
		ELSE SVMXC__Resolution_Customer_By__c AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'
		END as PrefStartTime
	,s.SVMXC__Order_Type__c as 'Order Type'
	,s.SVMXC__Order_Status__c as 'Order Status'
	,s.SVMX_PS_Filtration__c as 'Filtration'
	,s.SVMX_PS_IP_Q_Number_Short__c as 'SerialLabel'
	,zip_code__c as zip_id
	,s.Shed__c as ShedId
	,s.svmxc__company__c as account_id
	,s.Billable__c as IsBillable
	,CASE
		WHEN qSLA_Package__c LIKE '%Gold%'
		THEN 'Gold'
		WHEN qSLA_Package__c LIKE '%Platinum%'
		THEN 'Platinum'
		WHEN qSLA_Package__c LIKE '%Silver%'
		THEN 'Silver'
		WHEN qSLA_Package__c LIKE '%Bronze%'
		THEN 'Bronze'
		WHEN qSLA_Package__c LIKE '%Food%'
		THEN 'Food Service'
		ELSE 'Unknown'
	END as 'SLA'
	,s.Resolution_Code__c as 'Resolution Code'
	,s.Acquisition_Name__c as 'Acquisition Name'
	,s.Problem_Code__c as 'Problem Code'
	,SVMXC__Group_Member__c as TechID
	,s.Q_Number_In_c__c as 'Q Number In'
	,s.Q_Number_Out__c as 'Q Number Out'
	,s.Scanned_Q_Number__c as 'Scanned Q Number'
	,--ISNULL(
		ISNULL(s.SVMXC__Product__c, SMAX_PS_Field_Add_Product__c)--, wop.SVMXC__Product__c)
		--,sip.SVMXC__Product__c)
		as 'ProductKey'
	,s.Credit_Hold__c as CreditHold
	/* This was used to connect qWorkOrder types to SVMXC work order types
	,CASE
		WHEN q.[Work_Order_Type__c] = '_RELO_IN'	THEN 'Relocation In'
		WHEN q.[Work_Order_Type__c] = '_RELO_OUT'	THEN 'Relocation Out'
		WHEN q.[Work_Order_Type__c] = '_RELOSAME'	THEN 'Relocation Same'
		WHEN q.[Work_Order_Type__c] = '_RETRO'		THEN 'Retrofit'
		WHEN q.[Work_Order_Type__c] = '_CUSTPURCH'	THEN 'Customer Purchase'
		WHEN q.[Work_Order_Type__c] = '_SA'			THEN 'Site Audit'
		WHEN q.[Work_Order_Type__c] = '_PM'			THEN 'PM'
		WHEN q.[Work_Order_Type__c] = '_EM'			THEN 'Emergency'
		WHEN q.[Work_Order_Type__c] = '_STND'		THEN 'Standard'
		WHEN q.[Work_Order_Type__c] = '_AIRPM'		THEN 'PM'
		WHEN q.[Work_Order_Type__c] = '_PMTNM'		THEN 'PM TNM'
		WHEN q.[Work_Order_Type__c] = '_PURCH_INS'	THEN 'Purchase Install'
		WHEN q.[Work_Order_Type__c] = '_RMVL'		THEN 'Removal'
		WHEN q.[Work_Order_Type__c] = '_SWAP'		THEN 'Swap'
		WHEN q.[Work_Order_Type__c] = '_ROUTINE'	THEN 'Routine'
		WHEN q.[Work_Order_Type__c] = '_REPO'		THEN 'Repossession'
		WHEN q.[Work_Order_Type__c] = '_UPGD'		THEN 'Upgrade'
		WHEN q.[Work_Order_Type__c] = '_TS'			THEN 'Technical Survey'
		WHEN q.[Work_Order_Type__c] = '_INSTALL'	THEN 'Install'
		WHEN q.[Work_Order_Type__c] = '_COFFEE'		THEN 'Delivery'
		ELSE q.[Work_Order_Type__c]					END as 'QWO_Type'
		*/
	,CASE  -- identify if a work order was part of a project (i.e. Amazon)
		WHEN SVMXC__Order_Type__c IN ('Purchase Install', 'Install') AND SMAX_PS_Project_Name__c IS NOT NULL
		THEN 'Project'
		ELSE 'Single'
	END as InstallationType
	,SVMXC__Work_Performed__c as 'Work Performed'
	,SMAX_PS_Sales_Rep__c as SalesRep
	,CASE WHEN SVMXC__Order_Type__c IN ('Emergency'
									,'Standard'
									,'Routine'
									,'PM'
									,'PM TNM')
		AND SVMXC__Order_Type__c <> SVMX_PS_Override_Order_Type__c -- identify override swap work orders
		THEN SVMX_PS_Override_Order_Type__c
		WHEN SVMXC__Order_Type__c IN ('Emergency'
									,'Standard'
									,'Routine'
									,'PM'
									,'PM TNM')
		AND Q_Number_In_c__c <> Q_Number_Out__c
		THEN 'Swap'
		ELSE NULL
	END as OrderTypeOverride
	,SVMXC__Total_Billable_Amount__c as BillableAmount
	,s.Market__c as Market
	,qs.Service_Coverage__c as 'Service Coverage'
FROM Temporal.SVMXCServiceOrder s
	LEFT JOIN Temporal.QforceWorkOrder q on q.Id = qWork_Order__c
	LEFT JOIN Temporal.QforceSite qs on qs.Id = q.Site__c
	--LEFT JOIN #WO_WITHOUT_PRODUCTS wop on wop.id = s.id
	--LEFT JOIN [Temporal].[SVMXCServiceGroupMembers] u on u.[Id] = s.[SVMXC__Group_Member__c]
	--LEFT JOIN [Temporal].[SVMXCServiceGroupMembers] t on t.[Id] = s.[SVMXC__Preferred_Technician__c] -- if you need preferred technician, havent' found anything useful for it
	--LEFT JOIN [Temporal].[SVMXCInstalledProduct] sip on sip.[Q_Number__c] = Scanned_Q_Number__c AND sip.SVMXC__Status__c = 'Active'
WHERE SVMXC__Order_Type__c IS NOT NULL