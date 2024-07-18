---
title: Software
layout: publications
permalink: /software.html
---

# Academic Software

## PredictiveControl.jl

<span class=pub_icons><a href="https://github.com/imciner2/PredictiveControl.jl" target="_blank"><i class="fab fa-fw fa-github"></i>View on GitHub</a></span>

PredictiveControl.jl is a Julia package to construct and solve Model Predictive Control problems.
Currently, it allows for the specification of linear MPC problems, the formation of the condensed QP, and some some analysis of the problem/solvers.
It also includes an implementation of the Fast Gradient Method as a solver backend.

<p class="list_header">This package is under constant development, with the following improvements planned:</p>
 <ul class="list_header">
    <li>Real-time iteration solver for nonlinear MPC</li>
    <li>Additional optimization solvers (e.g. dual fast gradient, dual gradient projection, etc.)</li>
    <li>Additional analysis methods</li>
    <li>Additional condensing schemes</li>
    <li>Tube-based robust MPC</li>
</ul>

## ControlBenchmarks.jl

<span class=pub_icons><a href="https://github.com/imciner2/ControlBenchmarks.jl" target="_blank"><i class="fab fa-fw fa-github"></i>View on GitHub</a></span>

ControlBenchmarks.jl is a Julia package containing various pre-made control problems that can be used as benchmarks when doing design and analysis.
These benchmarks are taken from the literature, and also include various example systems such as mass-spring-damper chains.

## MATLAB Toolboxes

These MATLAB toolboxes have been developed over several years and contain various useful functions and algorithms from the research literature.

<p class="list_header">The various toolboxes are:</p>
 <ul class="list_header">
    <li><a href="https://github.com/imciner2/MATLAB_Toolbox" target="_blank">MATLAB Toolbox</a> - A toolbox containing generic and useful MATLAB functions.</li>
    <li><a href="https://github.com/imciner2/MPC_Toolbox" target="_blank">MPC Toolbox</a> - A toolbox for working iwth linear MPC problems in MATLAB.</li>
    <li><a href="https://github.com/imciner2/Control_Toolbox" target="_blank">Control Toolbox</a> - A toolbox that supplements the Mathworks Control Toolbox with additional functionality.</li>
    <li><a href="https://github.com/imciner2/Optimization_Toolbox" target="_blank">Optimization Toolbox</a> - A toolbox containing optimization methods.</li>
    <li><a href="https://github.com/imciner2/Numerical_Methods_Toolbox" target="_blank">Numerical Methods Toolbox</a> - A toolbox containing various numerical methods and algorithms.</li>
</ul>

## OSQP - The Operator Splitting Quadratic Program Solver

<span class=pub_icons><a href="https://github.com/oxfordcontrol/osqp" target="_blank"><i class="fab fa-fw fa-github"></i>View on GitHub</a></span>

The [OSQP](https://osqp.org) solver is an operator splitting solver for convex quadratic programs with sparse matrix structure written in C.
The solver can be built library-free, and generate standalone C code for problems that is suitable for use in embedded systems.
It can be interfaced to from several other languages, including MATLAB/Simulink.

My main contribution to this sofware has been software engineering on the core solver, maintaining the embedded implementation, and building a Simulink S-function interface.

# Other Software

## KiCad

<span class=pub_icons><a href="https://gitlab.com/kicad/code/kicad" target="_blank"><i class="fab fa-fw fa-gitlab"></i>View on GitLab</a></span>

[KiCad](https://kicad.org) is an open-source electronics design suite, encompassing schematic capture, circuit simulation and circuit board design.
I am a member of the lead development team, and am responsible for designing/implementing new features, triaging issue reports from users, implementing bug fixes, and reviewing contributions from other developers.
