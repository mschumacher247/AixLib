within AixLib.Systems.HeatPumpSystems;
model HeatPumpSystem
  "Model containing the basic heat pump block and different control blocks(optional)"

  Fluid.HeatPumps.HeatPump heatPump(
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
    final use_comIne=use_comIne,
    redeclare final model PerfData = PerfData,
    final scalingFactor=scalingFactor,
    final use_EvaCap=use_EvaCap,
    final use_ConCap=false)
    annotation (Placement(transformation(extent={{-24,-32},{26,28}})));
  Controls.HeatPump.SecurityControls.SecurityControl securityControl(
    final use_minRunTime=use_minRunTime,
    final minRunTime(displayUnit="min") = minRunTime,
    final minLocTime(displayUnit="min") = minLocTime,
    final use_runPerHou=use_runPerHou,
    final maxRunPerHou=maxRunPerHou,
    final use_opeEnv=use_opeEnv,
    final tableLow=tableLow,
    final tableUpp=tableUpp,
    final use_minLocTime=use_minLocTime,
    pre_n_start=pre_n_start,
    final use_deFro=use_deFro,
    final minIceFac=minIceFac,
    use_chiller=use_chiller,
    final calcPel_deFro=calcPel_deFro) if use_sec
    annotation (Placement(transformation(extent={{-102,-24},{-72,6}})));
  Controls.HeatPump.HPControl hPControls(final useAntilegionella=useAntLeg,
      redeclare model TSetToNSet = Controls.HeatPump.BaseClasses.OnOffHP,
    use_bivPar=use_bivPar,
    use_secHeaGen=use_secHeaGen,
    hys=hys)
    annotation (Placement(transformation(extent={{-102,18},{-72,48}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a1(
    redeclare final package Medium = Medium_eva,
    h_outflow(start=Medium_eva.h_default),
    m_flow(min=if allowFlowReversalEva then -Modelica.Constants.inf else 0))
    "Fluid connector a1 (positive design flow direction is from port_a1 to port_b1)"
    annotation (Placement(transformation(extent={{-70,110},{-50,130}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b1(
    redeclare final package Medium = Medium_eva,
    h_outflow(start=Medium_eva.h_default),
    m_flow(max=if allowFlowReversalEva then +Modelica.Constants.inf else 0))
    "Fluid connector b1 (positive design flow direction is from port_a1 to port_b1)"
    annotation (Placement(transformation(extent={{70,110},{50,130}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a2(
    redeclare final package Medium = Medium_con,
    h_outflow(start=Medium_con.h_default),
    m_flow(min=if allowFlowReversalCon then -Modelica.Constants.inf else 0))
    "Fluid connector a2 (positive design flow direction is from port_a2 to port_b2)"
    annotation (Placement(transformation(extent={{50,-130},{70,-110}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b2(
    redeclare final package Medium = Medium_con,
    h_outflow(start=Medium_con.h_default),
    m_flow(max=if allowFlowReversalCon then +Modelica.Constants.inf else 0))
    "Fluid connector b2 (positive design flow direction is from port_a2 to port_b2)"
    annotation (Placement(transformation(extent={{-50,-130},{-70,-110}})));
  parameter Boolean use_sec=true
    "False if the Security block should be disabled"
                                     annotation (choices(checkBox=true), Dialog(
        tab="Security Control", group="General", descriptionLabel = true));
  parameter Boolean use_deFro=true "False if defrost in not considered"
                                    annotation (choices(checkBox=true), Dialog(
        tab="Security Control",group="Defrost", descriptionLabel = true, enable=use_sec));

  Modelica.Blocks.Interfaces.RealInput T_oda "Outdoor air temperature"
    annotation (Placement(transformation(extent={{-150,64},{-120,94}})));
  parameter Boolean use_minRunTime=false
    "False if minimal runtime of HP is not considered"
    annotation (Dialog(tab="Security Control", group="On-/Off Control", descriptionLabel = true, enable=use_sec), choices(checkBox=true));
  parameter Modelica.SIunits.Time minRunTime=12000
    "Minimum runtime of heat pump"
    annotation (Dialog(tab="Security Control", group="On-/Off Control",
      enable=use_sec and use_minRunTime));
  parameter Boolean use_minLocTime=false
    "False if minimal locktime of HP is not considered"
    annotation (Dialog(tab="Security Control", group="On-/Off Control", descriptionLabel = true, enable=use_sec), choices(checkBox=true));
  parameter Modelica.SIunits.Time minLocTime=600
    "Minimum lock time of heat pump"
    annotation (Dialog(tab="Security Control", group="On-/Off Control",
      enable=use_sec and use_minLocTime));
  parameter Boolean use_runPerHou=false
    "False if maximal runs per hour of HP are not considered"
    annotation (Dialog(tab="Security Control", group="On-/Off Control", descriptionLabel = true, enable=use_sec), choices(checkBox=true));
  parameter Real maxRunPerHou=5
                              "Maximal number of on/off cycles in one hour"
    annotation (Dialog(tab="Security Control", group="On-/Off Control",
      enable=use_sec and use_runPerHou));
  parameter Boolean use_opeEnv=true
    "False to allow HP to run out of operational envelope"
    annotation (Dialog(tab="Security Control", group="Operational Envelope",
      enable=use_sec, descriptionLabel = true),choices(checkBox=true));
  parameter Boolean useAntLeg=false
    "True if Anti-Legionella control is considered"
    annotation (Dialog(tab="HP Control", group="Anti Legionella", descriptionLabel = true),choices(checkBox=true));
  Fluid.Movers.SpeedControlled_Nrpm pumSin(
    redeclare final package Medium = Medium_con,
    final allowFlowReversal=allowFlowReversalCon,
    final per=perEva,
    final addPowerToMedium=addPowerToMediumEva) if useConPum
    "Fan or pump at sink side of HP" annotation (Placement(transformation(
        extent={{8,-8},{-8,8}},
        rotation=90,
        origin={-20,54})));
  parameter Real tableUpp[:,2] "Upper boundary of envelope" annotation (Dialog(
      tab="Security Control",
      group="Operational Envelope",
      enable=use_sec and use_opeEnv));
  parameter Real tableLow[:,2] "Lower boundary of envelope" annotation (Dialog(
      tab="Security Control",
      group="Operational Envelope",
      enable=use_sec and use_opeEnv));
  Fluid.Movers.SpeedControlled_Nrpm pumSou(
    redeclare final package Medium = Medium_eva,
    final allowFlowReversal=allowFlowReversalEva,
    final per=perCon,
    final addPowerToMedium=addPowerToMediumCon) if useEvaPum
    "Fan or pump at source side of HP" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={26,-58})));
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
  parameter Fluid.Movers.Data.Generic perEva "Record with performance data"
    annotation (choicesAllMatching=true, Dialog(
      tab="Evaporator/ Condenser",
      group="Evaporator",
      enable=useEvaPum));
  parameter Boolean addPowerToMediumEva=true
    "Set to false to avoid any power (=heat and flow work) being added to medium (may give simpler equations)"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Evaporator",
      enable=useEvaPum));
  parameter Fluid.Movers.Data.Generic perCon "Record with performance data"
    annotation (choicesAllMatching=true, Dialog(
      tab="Evaporator/ Condenser",
      group="Condenser",
      enable=useConPum));
  parameter Boolean addPowerToMediumCon=true
    "Set to false to avoid any power (=heat and flow work) being added to medium (may give simpler equations)"
    annotation (Dialog(tab="Evaporator/ Condenser", group="Condenser",
      enable=useConPum));
  parameter Boolean use_comIne=false "Consider the inertia of the compressor"
    annotation (Dialog(group="Compressor Inertia"), choices(checkBox=true));
  constant Modelica.SIunits.Time comIneTime_constant
    "Time constant representing inertia of compressor"
    annotation (Dialog(group="Compressor Inertia", enable=use_comIne));
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
    annotation (Placement(transformation(extent={{-92,-44},{-78,-30}})));
  Fluid.Interfaces.PassThroughMedium mediumPassThroughSin(
    redeclare final package Medium = Medium_eva,
    final allowFlowReversal=allowFlowReversalEva,
    final m_flow_nominal=mFlow_evaNominal) if not useConPum annotation (
      Placement(transformation(
        extent={{6,-6},{-6,6}},
        rotation=90,
        origin={-46,50})));
  Fluid.Interfaces.PassThroughMedium mediumPassThroughSou(
    redeclare final package Medium = Medium_con,
    final allowFlowReversal=allowFlowReversalCon,
    final m_flow_nominal=mFlow_conNominal) if not useEvaPum annotation (
      Placement(transformation(
        extent={{-6,-6},{6,6}},
        rotation=90,
        origin={50,-58})));

  parameter Boolean use_secHeaGen=true "True if a bivalent setup is required" annotation(choices(checkBox=true), Dialog(
        group="System"));
  parameter Real scalingFactor=1
                               "Scaling-factor of HP";
  parameter Real minIceFac "Minimal value above which no defrost is necessary"
    annotation (Dialog(
      tab="Security Control",
      group="Defrost",
      enable=use_sec and use_deFro));
  parameter Boolean pre_n_start=false
                                     "Start value of pre(n) at initial time"
    annotation (Dialog(
      tab="Security Control",
      group="On-/Off Control",
      enable=use_sec), choices(checkBox=true));
  replaceable model secHeatGen =
      AixLib.Fluid.Interfaces.TwoPortHeatMassExchanger constrainedby
    AixLib.Fluid.Interfaces.PartialTwoPortInterface                                                                  annotation(Dialog(group="System", enable=
          use_secHeaGen), choicesAllMatching=true);

  secHeatGen secondHeaGen if use_secHeaGen annotation (Placement(transformation(
        extent={{12,-12},{-12,12}},
        rotation=-90,
        origin={32,62})));

  Fluid.Interfaces.PassThroughMedium mediumPassThroughSecHeaGen(
    redeclare final package Medium = Medium_eva,
    final allowFlowReversal=allowFlowReversalEva,
    final m_flow_nominal=mFlow_evaNominal) if not use_secHeaGen
    "Used if monovalent HP System" annotation (Placement(transformation(
        extent={{6,-6},{-6,6}},
        rotation=270,
        origin={64,62})));
  Fluid.Sensors.TemperatureTwoPort
                             senTSup(
    final transferHeat=true,
    redeclare final package Medium = Medium_con,
    final allowFlowReversal=allowFlowReversalCon,
    final m_flow_nominal=mFlow_conNominal,
    tauHeaTra=1200,
    T_start=308.15,
    final TAmb=291.15) "Supply temperature"
    annotation (Placement(transformation(extent={{-8,-8},{8,8}},
        rotation=90,
        origin={32,98})));

  parameter Boolean use_chiller=false
    "True if ice is defrost operates by changing mode to cooling. False to use an electrical heater"
    annotation (Dialog(
      tab="Security Control",
      group="Defrost",
      enable=use_sec and use_deFro), choices(checkBox=true));
  parameter Modelica.SIunits.Power calcPel_deFro
    "Calculate how much eletrical energy is used to melt ice. Insert a formular"
    annotation (Dialog(
      tab="Security Control",
      group="Defrost",
      enable=use_sec and use_deFro and use_chiller));

  parameter Boolean use_bivPar=true
    "Switch between bivalent parallel and bivalent alternative control"
    annotation (Dialog(group="System"),choices(choice=true "Parallel",
      choice=false "Alternativ",
      radioButtons=true));
  parameter Real hys=5 "Hysteresis of controller"
    annotation (Dialog(tab="HP Control", group="Control"));
equation
  connect(heatPump.sigBusHP, securityControl.sigBusHP) annotation (Line(
      points={{-26.75,-12.25},{-44,-12.25},{-44,-50},{-114,-50},{-114,-19.35},{-103.875,
          -19.35}},
      color={255,204,51},
      thickness=0.5));
  connect(T_oda,hPControls.T_oda)  annotation (Line(points={{-135,79},{-114,79},
          {-114,32.1},{-105,32.1}},  color={0,0,127}));
  if not useConPum then
  end if;
  connect(pumSin.port_b, heatPump.port_a1)
    annotation (Line(points={{-20,46},{-20,13},{-24,13}},
                                                 color={0,127,255},
      pattern=LinePattern.Dash));
  connect(pumSin.port_a, port_a1)
    annotation (Line(points={{-20,62},{-20,102},{-60,102},{-60,120}},
                                                color={0,127,255},
      pattern=LinePattern.Dash));
  if not useEvaPum then

  end if;
  connect(port_a2, pumSou.port_a)
    annotation (Line(points={{60,-120},{60,-98},{26,-98},{26,-68}},
                                                    color={0,127,255},
      pattern=LinePattern.Dash));
  connect(pumSou.port_b, heatPump.port_a2)
    annotation (Line(points={{26,-48},{26,-38},{26,-38},{26,-17}},
                                                     color={0,127,255},
      pattern=LinePattern.Dash));
  connect(heatPump.sigBusHP, hPControls.sigBusHP) annotation (Line(
      points={{-26.75,-12.25},{-44,-12.25},{-44,-50},{-114,-50},{-114,24.3},{-102.3,
          24.3}},
      color={255,204,51},
      thickness=0.5));
  connect(realPasThrSec.y, heatPump.nSet) annotation (Line(
      points={{-77.3,-37},{-56,-37},{-56,3},{-28,3}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(securityControl.nOut, heatPump.nSet) annotation (Line(
      points={{-70.75,-6},{-56,-6},{-56,3},{-28,3}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(port_a1, mediumPassThroughSin.port_a) annotation (Line(
      points={{-60,120},{-60,102},{-20,102},{-20,74},{-46,74},{-46,56}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(mediumPassThroughSin.port_b, heatPump.port_a1) annotation (Line(
      points={{-46,44},{-46,36},{-20,36},{-20,13},{-24,13}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(mediumPassThroughSou.port_a, port_a2) annotation (Line(
      points={{50,-64},{50,-80},{26,-80},{26,-98},{60,-98},{60,-120}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(mediumPassThroughSou.port_b, heatPump.port_a2) annotation (Line(
      points={{50,-52},{50,-40},{26,-40},{26,-17}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(hPControls.nOut, securityControl.nSet) annotation (Line(
      points={{-69.9,36},{-68,36},{-68,12},{-108,12},{-108,-6},{-104,-6}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(hPControls.nOut, realPasThrSec.u) annotation (Line(
      points={{-69.9,36},{-68,36},{-68,12},{-108,12},{-108,-37},{-93.4,-37}},
      color={0,0,127},
      pattern=LinePattern.Dash));
  connect(heatPump.port_b1, secHeaGen.port_a) annotation (Line(
      points={{26,13},{26,30},{32,30},{32,50}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(heatPump.port_b1, mediumPassThroughSecHeaGen.port_b) annotation (Line(
      points={{26,13},{26,30},{64,30},{64,68}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(port_b1, senTSup.port_b)
    annotation (Line(points={{60,120},{60,106},{32,106}},
                                                  color={0,127,255}));
  connect(secHeaGen.port_b, senTSup.port_a) annotation (Line(
      points={{32,74},{32,90}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(mediumPassThroughSecHeaGen.port_a, senTSup.port_a) annotation (Line(
      points={{64,56},{64,90},{32,90}},
      color={0,127,255},
      pattern=LinePattern.Dash));
  connect(senTSup.T, hPControls.TSup) annotation (Line(points={{23.2,98},{-110,98},
          {-110,42},{-106,42},{-106,41.1},{-105,41.1}},
                              color={0,0,127}));
  connect(heatPump.port_b2, port_b2) annotation (Line(points={{-24,-17},{-24,-98},
          {-60,-98},{-60,-120}}, color={0,127,255}));
  connect(hPControls.modeOut, securityControl.modeSet) annotation (Line(points={{-69.9,
          30},{-68,30},{-68,12},{-110,12},{-110,-12},{-104,-12}},        color={
          255,0,255}));
  connect(securityControl.modeOut, heatPump.modeSet) annotation (Line(points={{-70.75,
          -12},{-54,-12},{-54,-7},{-28,-7}}, color={255,0,255}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-120,-120},
            {120,120}})), Diagram(coordinateSystem(preserveAspectRatio=false,
          extent={{-120,-120},{120,120}})));
end HeatPumpSystem;
