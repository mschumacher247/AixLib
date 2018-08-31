within AixLib.Fluid.HeatPumps;
model HeatPumpSystem
  "Model containing the basic heat pump block and different control blocks(optional)"

  HeatPump heatPump(
    redeclare final package Medium_con = Medium_con,
    redeclare final package Medium_eva = Medium_eva,
    final allowFlowReversalEva=allowFlowReversalEva,
    final allowFlowReversalCon=allowFlowReversalCon,
    final mFlow_conNominal=mFlow_conNominal,
    final mFlow_evaNominal=mFlow_evaNominal,
    final VCon=VCon,
    final VEva=VEva,
    final dpEva_nominal=dpEva_nominal,
    final dpCon_nominal=dpCon_nominal,
    final comIneTime_constant=comIneTime_constant,
    final CEva=CEva,
    final GEva=GEva,
    final CCon=CCon,
    final GCon=GCon,
    final use_ComIne=useComIne,
    redeclare final model PerfData = PerfData,
    final scalingFactor=scalingFactor,
    final use_EvaCap=use_EvaCap,
    final use_ConCap=false)
    annotation (Placement(transformation(extent={{84,-38},{160,38}})));
  Controls.HeatPump.SecurityControls.SecurityControl securityControl(
    final useMinRunTime=useMinRunTime,
    final minRunTime(displayUnit="min") = minRunTime,
    final minLocTime(displayUnit="min") = minLocTime,
    final useRunPerHou=useRunPerHou,
    final maxRunPerHou=maxRunPerHou,
    final useOpeEnv=useOpeEnv,
    final tableLow=tableLow,
    final tableUpp=tableUpp,
    final useMinLocTime=useMinLocTime,
    use_deFro=use_deFro,
    minIceFac=minIceFac,
    pre_n_start=pre_n_start) if
                            use_sec
    annotation (Placement(transformation(extent={{-14,-50},{52,8}})));
  Controls.HeatPump.HPControl hPControls(final useAntilegionella=useAntLeg,
      redeclare model TSetToNSet = Controls.HeatPump.BaseClasses.OnOffHP)
    annotation (Placement(transformation(extent={{-106,-52},{-44,8}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a1(
    redeclare final package Medium = Medium_eva,
    h_outflow(start=Medium_eva.h_default),
    m_flow(min=if allowFlowReversalEva then -Modelica.Constants.inf else 0))
    "Fluid connector a1 (positive design flow direction is from port_a1 to port_b1)"
    annotation (Placement(transformation(extent={{74,90},{94,110}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b1(
    redeclare final package Medium = Medium_eva,
    h_outflow(start=Medium_eva.h_default),
    m_flow(max=if allowFlowReversalEva then +Modelica.Constants.inf else 0))
    "Fluid connector b1 (positive design flow direction is from port_a1 to port_b1)"
    annotation (Placement(transformation(extent={{170,90},{150,110}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a2(
    redeclare final package Medium = Medium_con,
    h_outflow(start=Medium_con.h_default),
    m_flow(min=if allowFlowReversalCon then -Modelica.Constants.inf else 0))
    "Fluid connector a2 (positive design flow direction is from port_a2 to port_b2)"
    annotation (Placement(transformation(extent={{150,-110},{170,-90}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b2(
    redeclare final package Medium = Medium_con,
    h_outflow(start=Medium_con.h_default),
    m_flow(max=if allowFlowReversalCon then +Modelica.Constants.inf else 0))
    "Fluid connector b2 (positive design flow direction is from port_a2 to port_b2)"
    annotation (Placement(transformation(extent={{94,-110},{74,-90}})));
  parameter Boolean use_sec=true
    "False if the Security block should be disabled"
                                     annotation (choices(checkBox=true), Dialog(
        tab="Security Control", group="General", descriptionLabel = true));
  parameter Boolean use_deFro=true "False if defrost in not considered"
                                    annotation (choices(checkBox=true), Dialog(
        tab="Security Control",group="Defrost", descriptionLabel = true, enable=use_sec));

  Modelica.Blocks.Interfaces.RealInput T_oda "Outdoor air temperature"
    annotation (Placement(transformation(extent={{-160,-42},{-120,-2}})));
  parameter Boolean useMinRunTime=true
    "False if minimal runtime of HP is not considered"
    annotation (Dialog(tab="Security Control", group="On-/Off Control", descriptionLabel = true, enable=use_sec), choices(checkBox=true));
  parameter Modelica.SIunits.Time minRunTime=12000
    "Minimum runtime of heat pump"
    annotation (Dialog(tab="Security Control", group="On-/Off Control",
      enable=use_sec and useMinRunTime));
  parameter Boolean useMinLocTime=true
    "False if minimal locktime of HP is not considered"
    annotation (Dialog(tab="Security Control", group="On-/Off Control", descriptionLabel = true, enable=use_sec), choices(checkBox=true));
  parameter Modelica.SIunits.Time minLocTime=600
    "Minimum lock time of heat pump"
    annotation (Dialog(tab="Security Control", group="On-/Off Control",
      enable=use_sec and useMinLocTime));
  parameter Boolean useRunPerHou=true
    "False if maximal runs per hour of HP are not considered"
    annotation (Dialog(tab="Security Control", group="On-/Off Control", descriptionLabel = true, enable=use_sec), choices(checkBox=true));
  parameter Real maxRunPerHou=5
                              "Maximal number of on/off cycles in one hour"
    annotation (Dialog(tab="Security Control", group="On-/Off Control",
      enable=use_sec and useRunPerHou));
  parameter Boolean useOpeEnv=true
    "False to allow HP to run out of operational envelope"
    annotation (Dialog(tab="Security Control", group="Operational Envelope",
      enable=useSecurity, descriptionLabel = true, enable=use_sec),                                                   choices(checkBox=true));
  parameter Boolean useAntLeg=false
    "True if Anti-Legionella control is considered"
    annotation (Dialog(tab="HP Control", group="Anti Legionella", descriptionLabel = true),choices(checkBox=true));
  Movers.SpeedControlled_Nrpm pumSin(
    redeclare final package Medium = Medium_con,
    final allowFlowReversal=allowFlowReversalCon,
    final per=perEva,
    final addPowerToMedium=addPowerToMediumEva) if useConPum
    "Fan or pump at sink side of HP" annotation (Placement(transformation(
        extent={{10,-10},{-10,10}},
        rotation=90,
        origin={102,64})));
  parameter Real tableUpp[:,2] "Upper boundary of envelope" annotation (Dialog(
      tab="Security Control",
      group="Operational Envelope",
      enable=use_sec and useOpeEnv));
  parameter Real tableLow[:,2] "Lower boundary of envelope" annotation (Dialog(
      tab="Security Control",
      group="Operational Envelope",
      enable=use_sec and useOpeEnv));
  Movers.SpeedControlled_Nrpm pumSou(
    redeclare final package Medium = Medium_eva,
    final allowFlowReversal=allowFlowReversalEva,
    final per=perCon,
    final addPowerToMedium=addPowerToMediumCon) if useEvaPum
    "Fan or pump at source side of HP" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={160,-60})));
  replaceable package Medium_con = Modelica.Media.Interfaces.PartialMedium "Medium at sink side"
    annotation (choicesAllMatching=true);
  replaceable package Medium_eva = Modelica.Media.Interfaces.PartialMedium "Medium at source side"
    annotation (choicesAllMatching=true);
  parameter Modelica.SIunits.MassFlowRate mFlow_conNominal
    "Nominal mass flow rate, used for regularization near zero flow"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Condenser"));
  parameter Modelica.SIunits.MassFlowRate mFlow_evaNominal
    "Nominal mass flow rate"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Evaporator"));
  parameter Modelica.SIunits.Volume VCon "Volume in condenser"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Condenser"));
  parameter Modelica.SIunits.Volume VEva "Volume in evaporator"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Evaporator"));
  parameter Modelica.SIunits.PressureDifference dpEva_nominal
    "Pressure drop at nominal mass flow rate"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Evaporator"));
  parameter Modelica.SIunits.PressureDifference dpCon_nominal
    "Pressure drop at nominal mass flow rate"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Condenser"));
  parameter Boolean allowFlowReversalEva=false
    "= false to simplify equations, assuming, but not enforcing, no flow reversal"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Assumptions"),
                                                                        choices(checkBox=true));
  parameter Boolean allowFlowReversalCon=false
    "= false to simplify equations, assuming, but not enforcing, no flow reversal"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Assumptions"),
                                                                       choices(checkBox=true));
  parameter Boolean useConPum=true
    "True if pump or fan at condenser side are included into this model"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Condenser"),choices(checkBox=true));
  parameter Boolean useEvaPum=true
    "True if pump or fan at evaporator side are included into this model"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Evaporator"),choices(checkBox=true));
  parameter Movers.Data.Generic perEva
    "Record with performance data"
    annotation (choicesAllMatching=true,Dialog(tab="Evaporator/ Condenser", group="Evaporator",
      enable=useEvaPum));
  parameter Boolean addPowerToMediumEva=true
    "Set to false to avoid any power (=heat and flow work) being added to medium (may give simpler equations)"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Evaporator",
      enable=useEvaPum));
  parameter Movers.Data.Generic perCon "Record with performance data"
    annotation (choicesAllMatching=true,Dialog(tab="Evaporator/ Condenser", group="Condenser",
      enable=useConPum));
  parameter Boolean addPowerToMediumCon=true
    "Set to false to avoid any power (=heat and flow work) being added to medium (may give simpler equations)"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Condenser",
      enable=useConPum));
  parameter Boolean useComIne=false
                                   "Consider the inertia of the compressor"
    annotation (Dialog(group="Compressor Inertia"), choices(checkBox=true));
  constant Modelica.SIunits.Time comIneTime_constant
    "Time constant representing inertia of compressor"
    annotation (Dialog(group="Compressor Inertia", enable=useComIne));
  parameter Boolean use_ConCap=false
    "If heat losses at capacitor side are considered or not"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Condenser"),
                                          choices(checkBox=true));
  parameter Boolean use_EvaCap=false
    "If heat losses at capacitor side are considered or not"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Evaporator"),
                                          choices(checkBox=true));
  parameter Modelica.SIunits.HeatCapacity CEva
    "Heat capacity of Evaporator (= cp*m)"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Evaporator",
      enable=use_EvaCap));
  parameter Modelica.SIunits.ThermalConductance GEva
    "Constant thermal conductance of Evaporator material"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Evaporator",
      enable=use_EvaCap));
  parameter Modelica.SIunits.HeatCapacity CCon
    "Heat capacity of Condenser (= cp*m)"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Condenser",
      enable=use_ConCap));
  parameter Modelica.SIunits.ThermalConductance GCon
    "Constant thermal conductance of condenser material"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Condenser",
      enable=use_ConCap));

  replaceable model PerfData =
      AixLib.Fluid.HeatPumps.BaseClasses.PerformanceData.BaseClasses.PartialPerformanceData
  "Replaceable model for performance data of HP"
    annotation (choicesAllMatching=true);
  Modelica.Blocks.Routing.RealPassThrough realPasThrSec if not use_sec
                                                                      "No 1. Layer"
    annotation (Placement(transformation(extent={{14,-94},{30,-78}})));
  Interfaces.PassThroughMedium mediumPassThroughSin(
    redeclare final package Medium = Medium_eva,
    final allowFlowReversal=allowFlowReversalEva,
    final m_flow_nominal=mFlow_evaNominal) if not useConPum annotation (
      Placement(transformation(
        extent={{6,-6},{-6,6}},
        rotation=90,
        origin={74,60})));
  Interfaces.PassThroughMedium mediumPassThroughSou(
    redeclare final package Medium = Medium_con,
    final allowFlowReversal=allowFlowReversalCon,
    final m_flow_nominal=mFlow_conNominal) if not useEvaPum annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=90,
        origin={182,-56})));

  parameter Real scalingFactor "Scaling-factor of HP";
  parameter Real minIceFac "Minimal value above which no defrost is necessary"
    annotation (Dialog(
      tab="Security Control",
      group="Defrost",
      enable=use_sec and use_deFro));
  parameter Boolean pre_n_start=true "Start value of pre(n) at initial time"
    annotation (Dialog(
      tab="Security Control",
      group="On-/Off Control",
      enable=use_sec));
equation
  connect(heatPump.sigBusHP, securityControl.sigBusHP) annotation (Line(
      points={{79.82,-12.9833},{74,-12.9833},{74,-70},{-28.675,-70},{-28.675,
          -41.01},{-18.125,-41.01}},
      color={255,204,51},
      thickness=0.5));
  connect(heatPump.port_b2, port_b2)
    annotation (Line(points={{84,-19},{84,-100}},   color={0,127,255}));
  connect(T_oda,hPControls.T_oda)  annotation (Line(points={{-140,-22},{-112.2,
          -22}},                     color={0,0,127}));
  connect(heatPump.port_b1, port_b1) annotation (Line(points={{160,19},{160,100}},
                      color={0,127,255}));
  if not useConPum then
  end if;
  connect(pumSin.port_b, heatPump.port_a1)
    annotation (Line(points={{102,54},{102,48},{84,48},{84,19}},
                                                 color={0,127,255},
      pattern=LinePattern.Dash));
  connect(pumSin.port_a, port_a1)
    annotation (Line(points={{102,74},{102,88},{84,88},{84,100}},
                                                color={0,127,255},
      pattern=LinePattern.Dash));
  if not useEvaPum then

  end if;
  connect(port_a2, pumSou.port_a)
    annotation (Line(points={{160,-100},{160,-70}}, color={0,127,255},
      pattern=LinePattern.Dash));
  connect(pumSou.port_b, heatPump.port_a2)
    annotation (Line(points={{160,-50},{160,-19}},   color={0,127,255},
      pattern=LinePattern.Dash));
  connect(heatPump.sigBusHP, hPControls.sigBusHP) annotation (Line(
      points={{79.82,-12.9833},{76,-12.9833},{76,-30},{74,-30},{74,-70},{-118,
          -70},{-118,-40},{-114,-40},{-114,-39.4},{-106.62,-39.4}},
      color={255,204,51},
      thickness=0.5));
  connect(realPasThrSec.y, heatPump.nSet) annotation (Line(
      points={{30.8,-86},{70,-86},{70,6.33333},{77.92,6.33333}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(securityControl.nOut, heatPump.nSet) annotation (Line(
      points={{54.75,-15.2},{66,-15.2},{66,6.33333},{77.92,6.33333}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(port_a1, mediumPassThroughSin.port_a) annotation (Line(
      points={{84,100},{74,100},{74,66}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(mediumPassThroughSin.port_b, heatPump.port_a1) annotation (Line(
      points={{74,54},{74,19},{84,19}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(mediumPassThroughSou.port_a, port_a2) annotation (Line(
      points={{182,-62},{182,-100},{160,-100}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(mediumPassThroughSou.port_b, heatPump.port_a2) annotation (Line(
      points={{182,-50},{182,-19},{160,-19}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(hPControls.nOut, securityControl.nSet) annotation (Line(
      points={{-39.66,-16},{-30,-16},{-30,-15.2},{-18.4,-15.2}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(hPControls.nOut, realPasThrSec.u) annotation (Line(
      points={{-39.66,-16},{-36,-16},{-36,-86},{12.4,-86}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(securityControl.modeOut, heatPump.modeSet) annotation (Line(points={{54.75,
          -26.8},{77.92,-26.8},{77.92,-6.33333}},       color={255,0,255}));
  connect(hPControls.modeOut, securityControl.modeSet) annotation (Line(points={{-39.66,
          -28},{-28,-28},{-28,-26.8},{-18.4,-26.8}},         color={255,0,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-120,-100},
            {200,100}})), Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-120,-100},{200,100}})));
end HeatPumpSystem;
