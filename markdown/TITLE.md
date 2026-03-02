\toc

# Raspberry Pi Pico as SCPI instrument

#### Description {-}

This document is an API reference for an SCPI-ish device implemented on Raspberry Pi Pico or
any RP2040 based microcontroller boards.

The RP2040 microcontroller has 2x I2C, 2x SPI, 2x UART, 16x PWM and 4x ADC peripherals multiplexed to 30x GPIOs.
In this implementation GPIO is limited down to 9, and there is no command for UART.
This primarily targets the Pico board and so that some GPIOs are reserved for other purpose and
no access from the API.

#### Tested devices {-}

- Raspberry Pi Pico
- Raspberry Pi Pico H

#### Untested devices {-}

- Raspberry Pi Pico W
- Raspberry Pi Pico WH
- Other third party RP2040 boards

#### Installation {-}

Two installation methods will be described here.
Either methods case you need to clone repository - <https://github.com/K4zuki/pipico-micropython-scpi>.
Also requires general python environment or Docker is required.

For python environment, [mpremote]{custom-style="PreprocessorTok"} module is required.

- `pip install mpremote`{.shell}

See document <https://docs.micropython.org/en/latest/reference/mpremote.html#mpremote> for more details.

#### Installation (1) - CDC class {-}

This applies to CDC class version.
Write official Micropython uf2 firmware (version 1.26), and put following files on root of target virtual filesystem directory.

- [mpremote cp MicroScpiDevice.py :MicroScpiDevice.py]{custom-style="PreprocessorTok"}
- [mpremote cp RaspberryScpiPico.py :RaspberryScpiPico.py]{custom-style="PreprocessorTok"}

and copy [main.py]{custom-style="PreprocessorTok"} from [cdc]{custom-style="PreprocessorTok"} directory:

- [mpremote cp cdc/main.py :main.py]{custom-style="PreprocessorTok"}

#### Installation (2) - TMC class {-}

This applies to TMC class version. Copy main two files [MicroScpiDevice.py]{custom-style="PreprocessorTok"} and
[RaspberryScpiPico.py]{custom-style="PreprocessorTok"} as well, plus files from [tmc]{custom-style="PreprocessorTok"} directory:

- [mpremote cp MicroScpiDevice.py :MicroScpiDevice.py]{custom-style="PreprocessorTok"}
- [mpremote cp RaspberryScpiPico.py :RaspberryScpiPico.py]{custom-style="PreprocessorTok"}
- [mpremote cp tmc/main.py :main.py]{custom-style="PreprocessorTok"}
- [mpremote cp tmc/Usb488ScpiPico.py :Usb488ScpiPico.py]{custom-style="PreprocessorTok"}
- [mpremote cp tmc/tmc.py :tmc.py]{custom-style="PreprocessorTok"}
- [mpremote cp tmc/usb488.py :usb488.py]{custom-style="PreprocessorTok"}

Also you will need to install a micropython module using mpremote:

- [mpremote mip install usb-core]{custom-style="PreprocessorTok"}

#### Installation (3) - build custom UF2 firmware {-}

Install Docker on your PC[^winpc-and-intelmac] and run [make docker]{custom-style="PreprocessorTok"} and
[make firmware]{custom-style="PreprocessorTok"} to build docker image and uf2 firmware respectively
(firmware build requires docker image).
This builds [pipco-micropython-scpi.uf2]{custom-style="PreprocessorTok"} firmeare in build directory.

WSL is recommended to use [make]{custom-style="PreprocessorTok"} on Windows i.e.
[wsl.exe make docker]{custom-style="PreprocessorTok"} and [wsl.exe make firmware]{custom-style="PreprocessorTok"}.

For any question, create an issue on github repo.

[^winpc-and-intelmac]: Tested with Windows PCs and Intel Mac environment only.
Either docker build or compile may fail with A1/2/3 chipset Mac and Linux.

#### Pin assignment {-}

Following tables [@tbl:special-functions] and [@tbl:pico-pinout] show function assignment for Pico.
There is also RP2040 GPIO# column applies to other third party boards.

::: {.table width=[0.18,0.22,0.6]}

Table: API unavailable or special functioned GPIO pins {#tbl:special-functions}

| RP2040<br>GPIO# | API subsystem | Note                                   |
|:---------------:|:-------------:|----------------------------------------|
|        0        |      NA       | No error indicator                     |
|        1        |      NA       | Error indicator                        |
|       23        |      NA       | (Pico) Onboard DC-DC converter control |
|       24        |      NA       | (Pico) VBUS status readout             |
|       25        | LED, PIN, PWM | (Pico) Onboard LED                     |
|       29        |      ADC      | (Pico) VSYS/3 voltage readout          |
|       NA        |      ADC      | (Pico) Core temperature readout        |

:::

\newpage

<div class="table" width="[0.25,0.15,0.1,0.1,0.15,0.25]">

Table: Raspberry Pi Pico pinout and function assignment {#tbl:pico-pinout}

|                                                                                                 Pico<br>Function | RP2040<br>GPIO# | Pico<br>Pin | Pico<br>Pin | RP2040<br>GPIO# | Pico<br>Function                                                                                                 |
|-----------------------------------------------------------------------------------------------------------------:|:---------------:|:-----------:|:-----------:|:---------------:|:-----------------------------------------------------------------------------------------------------------------|
|                                                                                               No error indicator |        0        |      1      |     40      |                 | [VBUS]{custom-style="PowerPinStyle"}                                                                             |
|                                                                                                  Error indicator |        1        |      2      |     39      |                 | [VSYS]{custom-style="PowerPinStyle"}                                                                             |
|                                                                             [GND]{custom-style="GroundPinStyle"} |                 |      3      |     38      |                 | [GND]{custom-style="GroundPinStyle"}                                                                             |
|                                                         [[SPI0 SCK]{custom-style="SPIPinStyle"}](#spi-subsystem) |        2        |      4      |     37      |                 | 3V3 EN                                                                                                           |
|                                                   [[SPI0 TX (MOSI)]{custom-style="SPIPinStyle"}](#spi-subsystem) |        3        |      5      |     36      |                 | 3V3 OUT                                                                                                          |
|                                                   [[SPI0 RX (MISO)]{custom-style="SPIPinStyle"}](#spi-subsystem) |        4        |      6      |     35      |                 | [[ADC VREF]{custom-style="ADCPinStyle"}](#adc-subsystem)                                                         |
|                                                          [[SPI0 CS]{custom-style="SPIPinStyle"}](#spi-subsystem) |        5        |      7      |     34      |       28        | [[ADC2]{custom-style="ADCPinStyle"}](#adc-subsystem)                                                             |
|                                                                             [GND]{custom-style="GroundPinStyle"} |                 |      8      |     33      |                 | [[ADC GND]{custom-style="ADCPinStyle"}](#adc-subsystem)                                                          |
|                                                         [[I2C1 SDA]{custom-style="I2CPinStyle"}](#i2c-subsystem) |        6        |      9      |     32      |       27        | [[ADC1]{custom-style="ADCPinStyle"}](#adc-subsystem)                                                             |
|                                                         [[I2C1 SCL]{custom-style="I2CPinStyle"}](#i2c-subsystem) |        7        |     10      |     31      |       26        | [[ADC0]{custom-style="ADCPinStyle"}](#adc-subsystem)                                                             |
|                                                         [[I2C0 SDA]{custom-style="I2CPinStyle"}](#i2c-subsystem) |        8        |     11      |     30      |                 | RUN                                                                                                              |
|                                                         [[I2C0 SCL]{custom-style="I2CPinStyle"}](#i2c-subsystem) |        9        |     12      |     29      |       22        | [[PIN 22]{custom-style="GPIOPinStyle"}](#pin-subsystem), [[PWM 22]{custom-style="GPIOPinStyle"}](#pwm-subsystem) |
|                                                                             [GND]{custom-style="GroundPinStyle"} |                 |     13      |     28      |                 | [GND]{custom-style="GroundPinStyle"}                                                                             |
|                                                         [[SPI1 SCK]{custom-style="SPIPinStyle"}](#spi-subsystem) |       10        |     14      |     27      |       21        | [[PIN 21]{custom-style="GPIOPinStyle"}](#pin-subsystem), [[PWM 21]{custom-style="GPIOPinStyle"}](#pwm-subsystem) |
|                                                   [[SPI1 TX (MOSI)]{custom-style="SPIPinStyle"}](#spi-subsystem) |       11        |     15      |     26      |       20        | [[PIN 20]{custom-style="GPIOPinStyle"}](#pin-subsystem), [[PWM 20]{custom-style="GPIOPinStyle"}](#pwm-subsystem) |
|                                                   [[SPI1 RX (MISO)]{custom-style="SPIPinStyle"}](#spi-subsystem) |       12        |     16      |     25      |       19        | [[PIN 19]{custom-style="GPIOPinStyle"}](#pin-subsystem), [[PWM 19]{custom-style="GPIOPinStyle"}](#pwm-subsystem) |
|                                                          [[SPI1 CS]{custom-style="SPIPinStyle"}](#spi-subsystem) |       13        |     17      |     24      |       18        | [[PIN 18]{custom-style="GPIOPinStyle"}](#pin-subsystem), [[PWM 18]{custom-style="GPIOPinStyle"}](#pwm-subsystem) |
|                                                                             [GND]{custom-style="GroundPinStyle"} |                 |     18      |     23      |                 | [GND]{custom-style="GroundPinStyle"}                                                                             |
| [[PIN 14]{custom-style="GPIOPinStyle"}](#pin-subsystem), [[PWM 14]{custom-style="GPIOPinStyle"}](#pwm-subsystem) |       14        |     19      |     22      |       17        | [[PIN 17]{custom-style="GPIOPinStyle"}](#pin-subsystem), [[PWM 17]{custom-style="GPIOPinStyle"}](#pwm-subsystem) |
| [[PIN 15]{custom-style="GPIOPinStyle"}](#pin-subsystem), [[PWM 15]{custom-style="GPIOPinStyle"}](#pwm-subsystem) |       15        |     20      |     21      |       16        | [[PIN 16]{custom-style="GPIOPinStyle"}](#pin-subsystem), [[PWM 16]{custom-style="GPIOPinStyle"}](#pwm-subsystem) |

</div>

# Parameter types

Parameter types with [mark]{custom-style="RegionMarkerTok"} applies to this implementation.

[[\<NR1\>]{custom-style="RegionMarkerTok"}]{#nr1}

:   Digits with an implied decimal point assumed at the right of the least-significant digit.\
Example: [273]{custom-style="StringTok"}

[`<NR2>`]{#nr2}

:   Digits with an explicit decimal point.\
Example: [27.3]{custom-style="StringTok"}

[`<NR3>`]{#nr3}

:   Digits with an explicit decimal point and an exponent.\
Example: [2.73E+02]{custom-style="StringTok"}

[[\<NR4\>]{custom-style="RegionMarkerTok"}]{#nr4}

:   Hexadecimal, even number of digits without a negative sign ["-"]{custom-style="PreprocessorTok"}.\
Example: [DEAD BEAF C00F3E]{custom-style="StringTok"}

[`<NRf>`]{#nrf}

:   Extended format that includes [\<NR1\>]{custom-style="PreprocessorTok"},
[\<NR2\>]{custom-style="PreprocessorTok"}, and [\<NR3\>]{custom-style="PreprocessorTok"}.\
Examples: [273 27.3 2.73E+02]{custom-style="StringTok"}

[`<NRf+>`]{#nrf-plus}

:   Expanded decimal format that includes [\<NRf\>]{custom-style="PreprocessorTok"} and
[MIN]{custom-style="PreprocessorTok"}, [MAX]{custom-style="PreprocessorTok"}.\
Examples: [273 27.3 2.73E+02 MAX]{custom-style="StringTok"}
:   [MIN]{custom-style="PreprocessorTok"} and [MAX]{custom-style="PreprocessorTok"}
are the minimum and maximum limit values that are implicit in the range specification for the parameter.

[[\<Bool\>]{custom-style="RegionMarkerTok"}]{#bool}

:   Boolean Data. Can be numeric [(0, 1)]{custom-style="PreprocessorTok"} or named [(OFF, ON)]{custom-style="PreprocessorTok"}.

[[\<SPD\>]{custom-style="RegionMarkerTok"}]{#spd}

:   String Program Data. Programs string parameters enclosed in single or double quotes.

[[\<CPD\>]{custom-style="RegionMarkerTok"}]{#cpd}

:   Character Program Data. Programs discrete parameters. Accepts both the short form and long form.

[[\<SRD\>]{custom-style="RegionMarkerTok"}]{#srd}

:   String Response Data. Returns string parameters enclosed in single or double quotes.

[[\<CRD\>]{custom-style="RegionMarkerTok"}]{#crd}

:   Character Response Data. Returns discrete parameters. Only the short form of the parameter is returned.

[`<AARD>`]{#aard}

:   Arbitrary ASCII Response Data. Permits the return of undelimited 7-bit ASCII.
This data type has an implied message terminator.

[`<Block>`]{#block}

:   Arbitrary Block Response Data. Permits the return of definite length and indefinite length arbitrary response data.
This data type has an implied message terminator.

# MACHINE Subsystem {.subsection-toc}

## MACHINE:FREQuency {.unnumbered #machine-frequency}

#### Syntax {-}

[MACHINE:FREQuency \<frequency\>|MINimum|MAXimum|DEFault]{custom-style="ControlFlowTok"}

:   This command sets Pico's CPU clock frequency in Hz.
[\<frequency\>]{custom-style="PreprocessorTok"} must be between 100MHz and 264MHz inclusive.
Also sets to minimum, default or maximum frequency when keyword parameter applied.

    <div class="table" width="[0.2,0.6]">

    |               Keyword               |           CPU frequency [Hz]            |
    |:-----------------------------------:|:---------------------------------------:|
    | [MINimum]{custom-style="NormalTok"} | [100_000_000]{custom-style="NormalTok"} |
    | [MAXimum]{custom-style="NormalTok"} | [264_000_000]{custom-style="NormalTok"} |
    | [DEFault]{custom-style="NormalTok"} | [125_000_000]{custom-style="NormalTok"} |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                      | Type                                    | Range of values                                                                    |
|-------------------------------------------|-----------------------------------------|------------------------------------------------------------------------------------|
| [\<frequency\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | [100_000_000]{custom-style="NormalTok"} to [264_000_000]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"}   | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}                                |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`MACHINE:FREQ 250e6` [// CPU is overclocking at 250MHz]{custom-style="CommentTok"}
`MACHINE:FREQ DEF` [// CPU runs at default clock (125MHz)]{custom-style="CommentTok"}
:::

## MACHINE:FREQuency? {.unnumbered #machine-frequency-query}

#### Syntax {-}

[MACHINE:FREQuency? \[MINimum|MAXimum|DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns Pico's CPU clock frequency in Hz.
Also returns minimum, default and maximum frequency when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Range of values                                     |
|-----------------------------------------|-----------------------------------------|-----------------------------------------------------|
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"} |

</div>

#### Returned Query Format {-}

[[\<NR1\>]{custom-style="NormalTok"}](#nr1)

#### Example {-}

`MACHINE:FREQ?` [// Returns current running frequency in Hz]{custom-style="CommentTok"}

:   Typical Response: [125_000_000]{custom-style="StringTok"}

`MACHINE:FREQ? MAX` [// Returns maximum frequency in Hz]{custom-style="CommentTok"}

:   Typical Response: [264_000_000]{custom-style="StringTok"}

# SYSTEM Subsystem {.subsection-toc}

## SYSTem:Error? {.unnumbered #system-error-query}

#### Syntax {-}

[SYSTem:ERRor?]{custom-style="ControlFlowTok"}

:   This query returns error code and message from top of error queue (see following table for code and message).

    <div class="table" width="[0.15,0.45]">
    | Code | Message                     |
    |:----:|:----------------------------|
    |  0   | No error                    |
    | -102 | Syntax error                |
    | -108 | Parameter not allowed       |
    | -109 | Missing parameter           |
    | -113 | Undefined header            |
    | -121 | Invalid character in number |
    | -148 | Character data not allowed  |
    | -158 | String data not allowed     |
    | -222 | Data out of range           |
    | -223 | Too much data               |
    | -224 | Illegal parameter value     |
    | -333 | I2C bus error               |
    | -334 | SPI bus error               |
    | -481 | Parser failure              |
    | -482 | No response on last bulkout |
    | -483 | No response stock left      |

    </div>

#### Returned Query Format {-}

[[\<NR1\>]{custom-style="NormalTok"}](#nr1), [[\<SRD\>]{custom-style="NormalTok"}](#srd)

#### Example {-}

`SYSTem:ERRor?` [// Returns first error in error list]{custom-style="CommentTok"}

:   Typical Response: [0, 'No error']{custom-style="StringTok"}

# PIN Subsystem {.subsection-toc}

## PIN? {.unnumbered #pin-query}

#### Syntax {-}

[PIN?]{custom-style="ControlFlowTok"}

:   This query returns status of all available pins (mode, value).

    <div class="table" width="[0.4,0.3]">

    |                   Command                    |          Default value          |
    |:--------------------------------------------:|:-------------------------------:|
    | [PIN\<pin\>:MODE]{custom-style="NormalTok"}  | [IN]{custom-style="NormalTok"}  |
    | [PIN\<pin\>:Value]{custom-style="NormalTok"} | [OFF]{custom-style="NormalTok"} |

    </div>

#### Returned Query Format {-}

[[\<CRD\>]{custom-style="NormalTok"}](#crd)

#### Example {-}

`PIN?` [// Returns entire Pin status]{custom-style="CommentTok"}

:   Typical Response: <br>[
PIN14:MODE IN;PIN14:VALue OFF;
PIN15:MODE IN;PIN15:VALue OFF;
PIN16:MODE IN;PIN16:VALue OFF;
PIN17:MODE IN;PIN17:VALue OFF;
PIN18:MODE IN;PIN18:VALue OFF;
PIN19:MODE IN;PIN19:VALue OFF;
PIN20:MODE IN;PIN20:VALue OFF;
PIN21:MODE IN;PIN21:VALue OFF;
PIN22:MODE IN;PIN22:VALue OFF;
PIN25:MODE IN;PIN25:VALue OFF;]{custom-style="StringTok"}

## PIN:MODE {.unnumbered #pin-mode}

#### Syntax {-}

[PIN\<pin\>:MODE \<mode\>]{custom-style="ControlFlowTok"}

:   This command sets mode of specified IO pin.

    <div class="table" width="[0.2,0.4]">

    |                                 Keyword                                  |     Pin mode      |
    |:------------------------------------------------------------------------:|:-----------------:|
    | [INput]{custom-style="NormalTok"}<br>[DEFault]{custom-style="NormalTok"} |       Input       |
    |                    [OUTput]{custom-style="NormalTok"}                    | Push-pull output  |
    |                    [ODrain]{custom-style="NormalTok"}                    | Open-drain output |
    |                     [PWM]{custom-style="NormalTok"}                      |        PWM        |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                 | Type                                    | Values                                                      |
|--------------------------------------|-----------------------------------------|-------------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"}  | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"}   |
| [\<mode\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [INput/OUTput/ODrain/PWM/DEFault]{custom-style="NormalTok"} |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`PIN14:MODE OUTput` [// Sets Pin14 to output mode]{custom-style="CommentTok"}
:::

## PIN:MODE? {.unnumbered #pin-mode-query}

#### Syntax {-}

[PIN\<pin\>:MODE? \[DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns status of specified IO pin's mode.
Also returns default status when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                    |
|-----------------------------------------|-----------------------------------------|-----------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [DEFault]{custom-style="NormalTok"}                       |

</div>

#### Returned Query Format {-}

[[\<CRD\>]{custom-style="NormalTok"}](#crd)

#### Example {-}

`PIN14:MODE?` [// Returns Pin14 pin mode]{custom-style="CommentTok"}

:   Typical Response: [IN]{custom-style="StringTok"}

## PIN:VALue {.unnumbered #pin-value}

#### Syntax {-}

[PIN\<pin\>:VALue \<value\>]{custom-style="ControlFlowTok"}

:   This command sets logical value of specified IO pin.
Also sets default value when [DEFault]{custom-style="NormalTok"} keyword is applied.

    <div class="table" width="[0.2,0.6]">

    |                                                  Value                                                  | Logical value |
    |:-------------------------------------------------------------------------------------------------------:|:-------------:|
    |                     [1]{custom-style="NormalTok"}<br>[ON]{custom-style="NormalTok"}                     |      HI       |
    | [0]{custom-style="NormalTok"}<br>[OFF]{custom-style="NormalTok"}<br>[DEFault]{custom-style="NormalTok"} |      LO       |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                  | Type                                                                               | Values                                                    |
|---------------------------------------|------------------------------------------------------------------------------------|-----------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"}   | [[NR1]{custom-style="NormalTok"}](#nr1)                                            | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"} |
| [\<value\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1)<br>[[CPD]{custom-style="NormalTok"}](#cpd) | [0/1<br>ON/OFF/DEFault]{custom-style="NormalTok"}         |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`PIN14:VAL ON` [// Sets Pin14 to logic HI]{custom-style="CommentTok"} \
`PIN14:VALue 0` [// Sets Pin14 to logic LO]{custom-style="CommentTok"}
:::

## PIN:VALue? {.unnumbered #pin-value-query}

#### Syntax {-}

[PIN\<pin\>:VALue? \[DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns logical value of specified IO pin.
Also returns default value when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                    |
|-----------------------------------------|-----------------------------------------|-----------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [DEFault]{custom-style="NormalTok"}                       |

</div>

#### Returned Query Format {-}

[[\<Bool\>]{custom-style="NormalTok"}](#bool)

#### Example {-}

`PIN14:VAL?` [// Returns Pin14 pin value]{custom-style="CommentTok"}

:   Typical Response: [ON]{custom-style="StringTok"}

## PIN:ON {.unnumbered #pin-on}

#### Syntax {-}

[PIN\<pin\>:ON]{custom-style="ControlFlowTok"}

:   This command sets logical value of specified IO pin to logic HI.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                | Type                                    | Values                                                    |
|-------------------------------------|-----------------------------------------|-----------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"} |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`PIN14:ON` [// Sets Pin14 to logic HI]{custom-style="CommentTok"} \
:::

## PIN:OFF {.unnumbered #pin-off}

#### Syntax {-}

[PIN\<pin\>:OFF]{custom-style="ControlFlowTok"}

:   This command sets logical value of specified IO pin to logic LO.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                | Type                                    | Values                                                    |
|-------------------------------------|-----------------------------------------|-----------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"} |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`PIN14:OFF` [// Sets Pin14 to logic LO]{custom-style="CommentTok"} \
:::

# PWM Subsystem {.subsection-toc}

## PWM? {.unnumbered #pwm-query}

#### Syntax {-}

[PWM?]{custom-style="ControlFlowTok"}

:   This query returns status of all available pins' PWM configuration (frequency, duty).

    <div class="table" width="[0.4,0.3]">

    |                     Command                      |           Default value            |
    |:------------------------------------------------:|:----------------------------------:|
    | [PWM\<pin\>:FREQuency]{custom-style="NormalTok"} | [1_000]{custom-style="NormalTok"}  |
    |   [PWM\<pin\>:DUTY]{custom-style="NormalTok"}    | [32_768]{custom-style="NormalTok"} |

    </div>

#### Returned Query Format {-}

[[\<CRD\>]{custom-style="NormalTok"}](#crd)

#### Example {-}

`PWM?` [// Returns entire Pin status]{custom-style="CommentTok"}

:   Typical Response: <br>[
PWM14:FREQuency 1_000;PWM14:DUTY 32_768;
PWM15:FREQuency 1_000;PWM15:DUTY 32_768;
PWM16:FREQuency 1_000;PWM16:DUTY 32_768;
PWM17:FREQuency 1_000;PWM17:DUTY 32_768;
PWM18:FREQuency 1_000;PWM18:DUTY 32_768;
PWM19:FREQuency 1_000;PWM19:DUTY 32_768;
PWM20:FREQuency 1_000;PWM20:DUTY 32_768;
PWM21:FREQuency 1_000;PWM21:DUTY 32_768;
PWM22:FREQuency 1_000;PWM22:DUTY 32_768;
PWM25:FREQuency 1_000;PWM25:DUTY 32_768;]{custom-style="StringTok"}

## PWM:FREQuency {.unnumbered #pwm-frequency}

#### Syntax {-}

[PWM\<pin\>:FREQuency \<frequency\>|MINimum|MAXimum|DEFault]{custom-style="ControlFlowTok"}

:   This command sets PWM frequency of specified IO pin in Hz.
Also sets to minimum, default or maximum frequency when keyword parameter applied.

    <div class="table" width="[0.2,0.6]">

    |               Keyword               |         PWM frequency [Hz]          |
    |:-----------------------------------:|:-----------------------------------:|
    | [MINimum]{custom-style="NormalTok"} |  [1_000]{custom-style="NormalTok"}  |
    | [MAXimum]{custom-style="NormalTok"} | [100_000]{custom-style="NormalTok"} |
    | [DEFault]{custom-style="NormalTok"} |  [1_000]{custom-style="NormalTok"}  |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                      | Type                                    | Values                                                                   |
|-------------------------------------------|-----------------------------------------|--------------------------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"}       | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"}                |
| [\<frequency\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | [1_000]{custom-style="NormalTok"} to [100_000]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"}   | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}                      |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`PWM14:FREQ 55_555` [// Pin14 PWM frequency is set at 55_555Hz]{custom-style="CommentTok"}
:::

## PWM:FREQuency? {.unnumbered #pwm-frequency-query}

#### Syntax {-}

[PWM\<pin\>:FREQuency? \[MINimum|MAXimum|DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns PWM frequency of specified IO pin in Hz.
Also returns minimum, default and maximum frequency when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                    |
|-----------------------------------------|-----------------------------------------|-----------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}       |

</div>

#### Returned Query Format {-}

[[\<NR1\>]{custom-style="NormalTok"}](#nr1)

#### Example {-}

`PWM14:FREQ?` [// Returns Pin14 PWM frequency in Hz]{custom-style="CommentTok"}

:   Typical Response: [500_000]{custom-style="StringTok"}

## PWM:DUTY {.unnumbered #pwm-duty}

#### Syntax {-}

[PWM\<pin\>:DUTY \<duty\>|MINimum|MAXimum|DEFault]{custom-style="ControlFlowTok"}

:   This command sets PWM duty of specified IO pin in range of 0 to 65535.
Also sets to minimum, default or maximum duty when keyword parameter applied.

    <div class="table" width="[0.2,0.6]">

    |               Keyword               |              PWM duty              |
    |:-----------------------------------:|:----------------------------------:|
    | [MINimum]{custom-style="NormalTok"} |   [0]{custom-style="NormalTok"}    |
    | [MAXimum]{custom-style="NormalTok"} | [65_535]{custom-style="NormalTok"} |
    | [DEFault]{custom-style="NormalTok"} | [32_768]{custom-style="NormalTok"} |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                             |
|-----------------------------------------|-----------------------------------------|--------------------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"}          |
| [\<duty\>]{custom-style="NormalTok"}    | [[NR1]{custom-style="NormalTok"}](#nr1) | [0]{custom-style="NormalTok"} to [65535]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}                |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`PWM14:DUTY 25_252` [// Pin14 PWM duty is set at 25252 out of 65535]{custom-style="CommentTok"}
:::

## PWM:DUTY? {.unnumbered #pwm-duty-query}

#### Syntax {-}

[PWM\<pin\>:DUTY? \[MINimum|MAXimum|DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns PWM duty of specified IO pin in range of 1 to 65535
Also returns minimum, default and maximum duty when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                    |
|-----------------------------------------|-----------------------------------------|-----------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}       |

</div>

#### Returned Query Format {-}

[[\<NR1\>]{custom-style="NormalTok"}](#nr1)

#### Example {-}

`PWM14:DUTY?` [// Returns Pin14 PWM duty in integer]{custom-style="CommentTok"}

:   Typical Response: [32_768]{custom-style="StringTok"}

## PWM:ON {.unnumbered #pwm-on}

#### Syntax {-}

[PWM\<pin\>:ON]{custom-style="ControlFlowTok"}

:   This command enables PWM mode on the pin and starts switching.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                | Type                                    | Values                                                    |
|-------------------------------------|-----------------------------------------|-----------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"} |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`PWM14:ON` [// Starts PWM switching]{custom-style="CommentTok"} \
:::

## PWM:OFF {.unnumbered #pwm-off}

#### Syntax {-}

[PWM\<pin\>:OFF]{custom-style="ControlFlowTok"}

:   This command disables PWM mode on the pin and goes to default pin mode.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                | Type                                    | Values                                                    |
|-------------------------------------|-----------------------------------------|-----------------------------------------------------------|
| [\<pin\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | [14/15/16/17/18/19/20/21/22/25]{custom-style="NormalTok"} |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`PWM14:OFF` [// Stops PWM switching and back to INput mode]{custom-style="CommentTok"} \
:::

# LED Subsystem {.subsection-toc}

## LED? {.unnumbered #led-query}

#### Syntax {-}

[LED?]{custom-style="ControlFlowTok"}

:   This query returns all status of onboard LED (value, PWM frequency, PWM duty).

    <div class="table" width="[0.3,0.6]">

    |                    Command                    |           Default value            |
    |:---------------------------------------------:|:----------------------------------:|
    |     [LED:VALue]{custom-style="NormalTok"}     |  [OFF]{custom-style="NormalTok"}   |
    | [LED:PWM:FREQuency]{custom-style="NormalTok"} | [1_000]{custom-style="NormalTok"}  |
    |   [LED:PWM:DUTY]{custom-style="NormalTok"}    | [32_768]{custom-style="NormalTok"} |

    </div>

#### Returned Query Format {-}

#### Example {-}

`LED?` [// Returns entire Pin status]{custom-style="CommentTok"}

:   Typical Response:\
[LED:VALue ON;LED:PWM:FREQuency 12_345;LED:PWM:DUTY 54_321]{custom-style="StringTok"}

## LED:ON {.unnumbered #led-on}

#### Syntax {-}

[LED:ON]{custom-style="ControlFlowTok"}

:   This command turns onboard LED on.

## LED:OFF {.unnumbered #led-off}

#### Syntax {-}

[LED:OFF]{custom-style="ControlFlowTok"}

:   This command turns onboard LED off.

## LED:VALue {.unnumbered #led-value}

#### Syntax {-}

[LED:VALue \<value\>|DEFault]{custom-style="ControlFlowTok"}

:   This command sets logical value of onboard LED.
Also sets default value when [DEFault]{custom-style="NormalTok"} keyword is applied.

    <div class="table" width="[0.2,0.6]">

    |                                                  Value                                                  | Logical value |
    |:-------------------------------------------------------------------------------------------------------:|:-------------:|
    |                     [1]{custom-style="NormalTok"}<br>[ON]{custom-style="NormalTok"}                     |      HI       |
    | [0]{custom-style="NormalTok"}<br>[OFF]{custom-style="NormalTok"}<br>[DEFault]{custom-style="NormalTok"} |      LO       |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                  | Type                                                                               | Values                                            |
|---------------------------------------|------------------------------------------------------------------------------------|---------------------------------------------------|
| [\<value\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1)<br>[[CPD]{custom-style="NormalTok"}](#cpd) | [0/1<br>ON/OFF/DEFault]{custom-style="NormalTok"} |

</div>

## LED:VALue? {.unnumbered #led-value-query}

#### Syntax {-}

[LED:VALue? \[DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns logical value of onboard LED. Also returns default value when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                              |
|-----------------------------------------|-----------------------------------------|-------------------------------------|
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [DEFault]{custom-style="NormalTok"} |

</div>

#### Returned Query Format {-}

[[\<Bool\>]{custom-style="NormalTok"}](#bool)

#### Example {-}

`LED:VALue?`

:   Typical Response: [ON]{custom-style="StringTok"}

## LED:PWM:ON {.unnumbered #led-pwm-on}

#### Syntax {-}

[PWM\<pin\>:ON]{custom-style="ControlFlowTok"}

:   This command enables PWM mode on the pin and starts switching.

#### Example {-}

:::{custom-style="Definition Term"}
`LED:PWM:ON` [// Starts PWM switching]{custom-style="CommentTok"} \
:::

## LED:PWM:OFF {.unnumbered #led-pwm-off}

#### Syntax {-}

[PWM\<pin\>:OFF]{custom-style="ControlFlowTok"}

:   This command disables PWM mode on the pin and goes to default pin mode.

#### Example {-}

:::{custom-style="Definition Term"}
`LED:PWM::OFF` [// Stops PWM switching and back to INput mode]{custom-style="CommentTok"} \
:::

## LED:PWM:FREQuency {.unnumbered #led-pwm-frequency}

#### Syntax {-}

[LED:PWM:FREQuency \<frequency\>|MINimum|MAXimum|DEFault]{custom-style="ControlFlowTok"}

:   This command sets PWM frequency of onboard LED in Hz.
Also sets to minimum, default or maximum frequency when keyword parameter applied.

    <div class="table" width="[0.2,0.6]">

    |               Keyword               |         PWM frequency [Hz]          |
    |:-----------------------------------:|:-----------------------------------:|
    | [MINimum]{custom-style="NormalTok"} |  [1_000]{custom-style="NormalTok"}  |
    | [MAXimum]{custom-style="NormalTok"} | [100_000]{custom-style="NormalTok"} |
    | [DEFault]{custom-style="NormalTok"} |  [1_000]{custom-style="NormalTok"}  |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                      | Type                                    | Values                                                                   |
|-------------------------------------------|-----------------------------------------|--------------------------------------------------------------------------|
| [\<frequency\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | [1_000]{custom-style="NormalTok"} to [100_000]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"}   | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}                      |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`LED:PWM:FREQ 55_555` [// LED PWM frequency is set at 55_555Hz]{custom-style="CommentTok"}
:::

## LED:PWM:FREQuency? {.unnumbered #led-pwm-frequency-query}

#### Syntax {-}

[LED:PWM:FREQuency? \[MINimum|MAXimum|DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns PWM frequency of onboard LED in Hz.
Also returns minimum, default and maximum frequency when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                              |
|-----------------------------------------|-----------------------------------------|-----------------------------------------------------|
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"} |

</div>

#### Returned Query Format {-}

[[\<NR1\>]{custom-style="NormalTok"}](#nr1)

#### Example {-}

`LED:PWM:FREQ?` [// Returns Pin14 PWM frequency in Hz]{custom-style="CommentTok"}

:   Typical Response: [500_000]{custom-style="StringTok"}

## LED:PWM:DUTY {.unnumbered #led-pwm-duty}

#### Syntax {-}

[LED:PWM:DUTY \<duty\>|MINimum|MAXimum|DEFault]{custom-style="ControlFlowTok"}

:   This command sets PWM duty of onboard LED in range of 0 to 65535.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                             |
|-----------------------------------------|-----------------------------------------|--------------------------------------------------------------------|
| [\<duty\>]{custom-style="NormalTok"}    | [[NR1]{custom-style="NormalTok"}](#nr1) | [0]{custom-style="NormalTok"} to [65535]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}                |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`LED:PWM:DUTY 25_252` [// LED PWM duty is set at 25252 out of 65535]{custom-style="CommentTok"}
:::

## LED:PWM:DUTY? {.unnumbered #led-pwm-duty-query}

#### Syntax {-}

[LED:PWM:DUTY? \[MINimum|MAXimum|DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns PWM duty of onboard LED in range of 1 to 65535.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                              |
|-----------------------------------------|-----------------------------------------|-----------------------------------------------------|
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"} |

</div>

#### Returned Query Format {-}

[[\<NR1\>]{custom-style="NormalTok"}](#nr1)

#### Example {-}

`LED:PWM:DUTY?` [// Returns LED PWM duty in integer]{custom-style="CommentTok"}

:   Typical Response: [32_768]{custom-style="StringTok"}

# I2C Subsystem {.subsection-toc}

## I2C? {.unnumbered #i2c-query}

#### Syntax {-}

[I2C?]{custom-style="ControlFlowTok"}

:   This query returns all status of I2C buses (addressing, clock frequency).

    <div class="table" width="[0.3,0.4]">

    |                      Command                       |            Default value            |
    |:--------------------------------------------------:|:-----------------------------------:|
    | [I2C\<bus\>:ADDRess:BIT]{custom-style="NormalTok"} |    [1]{custom-style="NormalTok"}    |
    |  [I2C\<bus\>:FREQuency]{custom-style="NormalTok"}  | [100_000]{custom-style="NormalTok"} |

    </div>

#### Returned Query Format {-}

#### Example {-}

`I2C?` [// Returns I2C bus status]{custom-style="CommentTok"}

:   Typical Response: \
[I2C0:ADDRess:BIT 1;I2C0:FREQuency 100_000;I2C1:ADDRess:BIT 1;I2C1:FREQuency 100_000;]{custom-style="StringTok"}

## I2C:SCAN? {.unnumbered #i2c-scan-query}

#### Syntax {-}

[I2C\<bus\>:SCAN?]{custom-style="ControlFlowTok"}

:   This query returns list of I2C slave device on the specified bus.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                | Type                                    | Values                                                                    |
|-------------------------------------|-----------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |

</div>

#### Returned Query Format {-}

[[\<NR4\>\[,\<NR4\>\]]{custom-style="NormalTok"}](#nr4)

#### Example {-}

`I2C0:SCAN?` [// Scans slave devices on I2C0 bus]{custom-style="CommentTok"}

:   Typical Response: [A6,5A,80,EE]{custom-style="StringTok"} when 8-bit addressing.\
[53,2D,40,77]{custom-style="StringTok"} when 7-bit addressing

## I2C:FREQuency {.unnumbered #i2c-frequency}

#### Syntax {-}

[I2C\<bus\>:FREQuency \<frequency\>|MINimum|MAXimum|DEFault]{custom-style="ControlFlowTok"}

:   This command sets clock frequency of specified bus.
Also sets to minimum, default or maximum frequency when keyword parameter applied.

    <div class="table" width="[0.2,0.6]">

    |               Keyword               |         PWM frequency [Hz]          |
    |:-----------------------------------:|:-----------------------------------:|
    | [MINimum]{custom-style="NormalTok"} | [10_000]{custom-style="NormalTok"}  |
    | [MAXimum]{custom-style="NormalTok"} | [400_000]{custom-style="NormalTok"} |
    | [DEFault]{custom-style="NormalTok"} | [100_000]{custom-style="NormalTok"} |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                      | Type                                    | Values                                                                    |
|-------------------------------------------|-----------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}       | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<frequency\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | [10_000]{custom-style="NormalTok"} to [400_000]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"}   | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}                       |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`I2C0:FREQ 55_555` [// I2C0 bus frequency is set at 55.555kHz]{custom-style="CommentTok"}
:::

## I2C:FREQuency? {.unnumbered #i2c-frequency-query}

#### Syntax {-}

[I2C\<bus\>:FREQuency? \[MINimum|MAXimum|DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns clock frequency of specified bus.
Also returns minimum, default and maximum frequency when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                                    |
|-----------------------------------------|-----------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}                       |

</div>

#### Returned Query Format {-}

[[\<NR1\>]{custom-style="NormalTok"}](#nr1)

#### Example {-}

`I2C1:FREQuency?` [// Returns bus clock frequency setting in Hz]{custom-style="CommentTok"}

:   Typical Response: [400_000]{custom-style="StringTok"}

## I2C:ADDRess:BIT {.unnumbered #i2c-address-bit}

#### Syntax {-}

[I2C\<bus\>:ADDRess:BIT \<bit\>|DEFault]{custom-style="ControlFlowTok"}

:   This command sets addressing of specified bus.
Also sets default value when keyword parameter applied.

    <div class="table" width="[0.2,0.6]">

    |                                Value                                 | Addressing |
    |:--------------------------------------------------------------------:|:----------:|
    |                    [0]{custom-style="NormalTok"}                     |   7-bit    |
    | [1]{custom-style="NormalTok"}<br>[DEFault]{custom-style="NormalTok"} |   8-bit    |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                                    |
|-----------------------------------------|-----------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<bit\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus addressing                                                            |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [DEFault]{custom-style="NormalTok"}                                       |

</div>

#### Example {-}

:::{custom-style="Definition Term"}
`I2C0:ADDR:BIT 0` [// I2C0 uses 7-bit addressing]{custom-style="CommentTok"}
:::

## I2C:ADDRess:BIT? {.unnumbered #i2c-address-bit-query}

#### Syntax {-}

[I2C\<bus\>:ADDRess:BIT? \[DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns addressing of specified bus.
Also returns default value when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                                    |
|-----------------------------------------|-----------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [DEFault]{custom-style="NormalTok"}                                       |

</div>

#### Returned Query Format {-}

[[\<NR1\>]{custom-style="NormalTok"}](#nr1)

#### Example {-}

`I2C0:ADDRess:BIT?` [// Returns addressing setting in integer]{custom-style="CommentTok"}

:   Typical Response: [0]{custom-style="StringTok"}

## I2C:WRITE {.unnumbered #i2c-write}

#### Syntax {-}

[I2C\<bus\>:WRITE \<address\>,\<buffer\>,\<stop\>]{custom-style="ControlFlowTok"}

:   This command writes list of hexadecimal to specified slave device on the bus.
Stop condition is configured by \<stop\>.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                                   | Values                                                                                                                                                                     |
|-----------------------------------------|--------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1)                | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"}                                                                                                  |
| [\<address\>]{custom-style="NormalTok"} | [[NR4]{custom-style="NormalTok"}](#nr4)                | [02]{custom-style="NormalTok"} to [FC]{custom-style="NormalTok"} (8-bit addressing)<br>[01]{custom-style="NormalTok"} to [7E]{custom-style="NormalTok"} (7-bit addressing) |
| [\<buffer\>]{custom-style="NormalTok"}  | [[\<NR4\>\[\<NR4\>\]]{custom-style="NormalTok"}](#nr4) |                                                                                                                                                                            |
| [\<stop\>]{custom-style="NormalTok"}    | [[NR1]{custom-style="NormalTok"}](#nr1)                | [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"}                                                                                                             |

</div>

## I2C:READ? {.unnumbered #i2c-read-query}

#### Syntax {-}

[I2C\<bus\>:READ? \<address\>,\<length\>,\<stop\>]{custom-style="ControlFlowTok"}

:   This query reads \<length\> bytes of data from specified slave device on the bus.
Stop condition is configured by \<stop\>.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                                                                                                                                     |
|-----------------------------------------|-----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"}                                                                                                  |
| [\<address\>]{custom-style="NormalTok"} | [[NR4]{custom-style="NormalTok"}](#nr4) | [02]{custom-style="NormalTok"} to [FC]{custom-style="NormalTok"} (8-bit addressing)<br>[01]{custom-style="NormalTok"} to [7E]{custom-style="NormalTok"} (7-bit addressing) |
| [\<length\>]{custom-style="NormalTok"}  | [[NR1]{custom-style="NormalTok"}](#nr1) | 1 or larger                                                                                                                                                                |
| [\<stop\>]{custom-style="NormalTok"}    | [[NR1]{custom-style="NormalTok"}](#nr1) | [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"}                                                                                                             |

</div>

#### Returned Query Format {-}

[[\<NR4\>\[,\<NR4\>\]]{custom-style="NormalTok"}](#nr4)

#### Example {-}

`I2C0:READ? AA,4,1` [// Returns 4-bytes of data from slave device in list of hexadecimal texts]{custom-style="CommentTok"}

:   Typical Response: [DE,AD,BE,EF]{custom-style="StringTok"}

## I2C:MEMory:WRITE {.unnumbered #i2c-memory-write}

#### Syntax {-}

[I2C\<bus\>:MEMory:WRITE \<address\>,\<memaddress\>,<br>\<buffer\>,\<addrsize\>]{custom-style="ControlFlowTok"}

:   This command sends stream of hexadecimal data into specified memory address of slave device.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                       | Type                                                   | Values                                                                                                                                                                     |
|--------------------------------------------|--------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}        | [[NR1]{custom-style="NormalTok"}](#nr1)                | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"}                                                                                                  |
| [\<address\>]{custom-style="NormalTok"}    | [[NR4]{custom-style="NormalTok"}](#nr4)                | [02]{custom-style="NormalTok"} to [FC]{custom-style="NormalTok"} (8-bit addressing)<br>[01]{custom-style="NormalTok"} to [7E]{custom-style="NormalTok"} (7-bit addressing) |
| [\<memaddress\>]{custom-style="NormalTok"} | [[NR4]{custom-style="NormalTok"}](#nr4)                | [00]{custom-style="NormalTok"} to [FF]{custom-style="NormalTok"}                                                                                                           |
| [\<buffer\>]{custom-style="NormalTok"}     | [[\<NR4\>\[\<NR4\>\]]{custom-style="NormalTok"}](#nr4) | Stream of data                                                                                                                                                             |
| [\<addrsize\>]{custom-style="NormalTok"}   | [[NR1]{custom-style="NormalTok"}](#nr1)                | [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"}                                                                                                             |

</div>

## I2C:MEMory:READ? {.unnumbered #i2c-memory-read-query}

#### Syntax {-}

[I2C\<bus\>:MEMory:READ? \<address\>,\<memaddress\>,<br>\<nbytes\>,\<addrsize\>]{custom-style="ControlFlowTok"}

:   This query returns comma separated list of hexadecimal data stored in specific memory address of
the target I2C slave device.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                       | Type                                    | Values                                                                                                                                                                     |
|--------------------------------------------|-----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}        | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"}                                                                                                  |
| [\<address\>]{custom-style="NormalTok"}    | [[NR4]{custom-style="NormalTok"}](#nr4) | [02]{custom-style="NormalTok"} to [FC]{custom-style="NormalTok"} (8-bit addressing)<br>[01]{custom-style="NormalTok"} to [7E]{custom-style="NormalTok"} (7-bit addressing) |
| [\<memaddress\>]{custom-style="NormalTok"} | [[NR4]{custom-style="NormalTok"}](#nr4) | [00]{custom-style="NormalTok"} to [FF]{custom-style="NormalTok"}                                                                                                           |
| [\<nbytes\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr4) | 1 or larger                                                                                                                                                                |
| [\<addrsize\>]{custom-style="NormalTok"}   | [[NR1]{custom-style="NormalTok"}](#nr1) | [1]{custom-style="NormalTok"} or [2]{custom-style="NormalTok"}                                                                                                             |

</div>

#### Returned Query Format {-}

[[\<NR4\>\[,\<NR4\>\]]{custom-style="NormalTok"}](#nr4)

#### Example {-}

`I2C1:MEMory:READ? 55,AA,4,1`  [// Returns 4-bytes of data from register 0xAA of slave device]{custom-style="CommentTok"}

:   Typical Response: [DE,AD,BE,EF]{custom-style="StringTok"}

# SPI Subsystem {.subsection-toc}

## SPI? {.unnumbered #spi-query}

#### Syntax {-}

[SPI?]{custom-style="ControlFlowTok"}

:   This query returns all status of SPI buses (chip select polarity, clock frequency, bus mode).

    <div class="table" width="[0.3,0.4]">

    |                       Command                        |             Default value             |
    |:----------------------------------------------------:|:-------------------------------------:|
    | [SPI\<bus\>:CSEL:POLarity]{custom-style="NormalTok"} |     [0]{custom-style="NormalTok"}     |
    |   [SPI\<bus\>:FREQuency]{custom-style="NormalTok"}   | [1_000_000]{custom-style="NormalTok"} |
    |     [SPI\<bus\>:MODE]{custom-style="NormalTok"}      |     [0]{custom-style="NormalTok"}     |

    </div>

#### Returned Query Format {-}

[[\<SRD\>]{custom-style="NormalTok"}](#srd)

#### Example {-}

`SPI?` [// Returns SPI bus status]{custom-style="CommentTok"}

:   Typical Response:\
[SPI0:CSEL:POLarity 0;SPI0:FREQuency 1_000_000;SPI0:MODE 0;
SPI1:CSEL:POLarity 0;SPI1:FREQuency 1_000_000;SPI1:MODE 0;]{custom-style="StringTok"}

## SPI:CSEL:POLarity {.unnumbered #spi-csel-polarity}

#### Syntax {-}

[SPI\<bus\>:CSEL:POLarity \<polarity\>|DEFault]{custom-style="ControlFlowTok"}

:   This command sets chip select polarity for specified SPI bus
Also sets default value when keyword parameter applied.

    <div class="table" width="[0.2,0.6]">

    |                                Value                                 | Polarity  |
    |:--------------------------------------------------------------------:|:---------:|
    |                    [1]{custom-style="NormalTok"}                     | HI-active |
    | [0]{custom-style="NormalTok"}<br>[DEFault]{custom-style="NormalTok"} | LO-active |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                     | Type                                      | Values                                                                    |
|------------------------------------------|-------------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}      | [[NR1]{custom-style="NormalTok"}](#nr1)   | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<polarity\>]{custom-style="NormalTok"} | [[Bool]{custom-style="NormalTok"}](#bool) | Chip select polarity                                                      |
| [\<keyword\>]{custom-style="NormalTok"}  | [[CPD]{custom-style="NormalTok"}](#cpd)   | [DEFault]{custom-style="NormalTok"}                                       |

</div>

#### Example {-}

`SPI0:CSEL:POLarity 1` [// Sets SPI0 chip select to HI-active]{custom-style="CommentTok"}

## SPI:CSEL:POLarity? {.unnumbered #spi-csel-polarity-query}

#### Syntax {-}

[SPI\<bus\>:CSEL:POLarity? \[DEFault\]]{custom-style="ControlFlowTok"}

:   This query returns chip select pin polarity for specified SPI bus
Also returns default value when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                                    |
|-----------------------------------------|-----------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [DEFault]{custom-style="NormalTok"}                                       |

</div>

#### Returned Query Format {-}

[[\<Bool\>]{custom-style="NormalTok"}](#bool)

#### Example {-}

`SPI0:CSEL:POLarity?` [// Returns SPI0 chip select polarity]{custom-style="CommentTok"}

:   Typical Response: [1]{custom-style="StringTok"}

## SPI:CSEL:VALue {.unnumbered #spi-csel-value}

#### Syntax {-}

[SPI\<bus\>:CSEL:VALue \<value\>|DEFault]{custom-style="ControlFlowTok"}

:   This command sets logical value of chip select pin for specified bus.
Also returns default value when keyword parameter applied.

    <div class="table" width="[0.2,0.6]">

    |                                                  Value                                                  |   Bus    |
    |:-------------------------------------------------------------------------------------------------------:|:--------:|
    |                     [1]{custom-style="NormalTok"}<br>[ON]{custom-style="NormalTok"}                     | Enabled  |
    | [0]{custom-style="NormalTok"}<br>[OFF]{custom-style="NormalTok"}<br>[DEFault]{custom-style="NormalTok"} | Disabled |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                      | Values                                                                    |
|-----------------------------------------|-------------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1)   | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<value\>]{custom-style="NormalTok"}   | [[Bool]{custom-style="NormalTok"}](#bool) | Logical value of CS pin.                                                  |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd)   | [DEFault]{custom-style="NormalTok"}                                       |

</div>

## SPI:CSEL:VALue? {.unnumbered #spi-csel-value-query}

#### Syntax {-}

[SPI\<bus\>:CSEL:VALue? \[DEFault\]]{.cf custom-style="ControlFlowTok"}

:   This query returns logical value of CS pin.
Also returns default value when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                                    |
|-----------------------------------------|-----------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [DEFault]{custom-style="NormalTok"}                                       |

</div>

#### Returned Query Format {-}

[[\<Bool\>]{custom-style="NormalTok"}](#bool)

#### Example {-}

`SPI0:CSEL:VALue?` [// Returns chip select pin value]{custom-style="CommentTok"}

:   Typical Response: [OFF]{custom-style=".st StringTok"}

## SPI:MODE {.unnumbered #spi-mode}

#### Syntax {-}

[SPI\<bus\>:MODE \<mode\>|DEFault]{.cf custom-style="ControlFlowTok"}

:   This command sets bus clock and phase mode for specified SPI bus
Also returns default value when keyword parameter applied.

    <div class="table" width="[0.15,0.15,0.15]">

    |                     Mode                     | CPOL |  CPHA   |
    |:--------------------------------------------:|:----:|:-------:|
    | **0**<br>[DEFault]{custom-style="NormalTok"} | Low  | Rising  |
    |                    **1**                     | Low  | Falling |
    |                    **2**                     | High | Rising  |
    |                    **3**                     | High | Falling |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                     | Type                                    | Values                                                                                                 |
|------------------------------------------|-----------------------------------------|--------------------------------------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}      | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"}                              |
| [\<mode\>]{.st custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus clock and phase mode<br>[0/1/2/3]{custom-style="NormalTok"} or [DEFault]{custom-style="NormalTok"} |

</div>

## SPI:MODE? {.unnumbered #spi-mode-query}

#### Syntax {-}

[SPI\<bus\>:MODE?]{custom-style="ControlFlowTok"}

:   This query returns bus clock and phase mode for specified SPI bus

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                | Type                                    | Values                                                                    |
|-------------------------------------|-----------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |

</div>

#### Returned Query Format {-}

[[<code>\<NR1\></code>]{custom-style="NormalTok"}](#nr1)

#### Example {-}

`SPI1:MODE?` [// Returns clock and phase mode for bus 1]{custom-style="CommentTok"}

:   Typical Response: [2]{custom-style="StringTok"}

## SPI:FREQuency {.unnumbered #spi-frequency}

#### Syntax {-}

[SPI\<bus\>:FREQuency \<frequency\>|MINimum|MAXimum|DEFault]]{custom-style="ControlFlowTok"}

:   This command sets bus clock frequency for specified bus.
Also sets to minimum, default or maximum frequency when keyword parameter applied.

    <div class="table" width="[0.2,0.6]">

    |               Keyword               |           PWM frequency [Hz]           |
    |:-----------------------------------:|:--------------------------------------:|
    | [MINimum]{custom-style="NormalTok"} |   [10_000]{custom-style="NormalTok"}   |
    | [MAXimum]{custom-style="NormalTok"} | [10_000_000]{custom-style="NormalTok"} |
    | [DEFault]{custom-style="NormalTok"} | [1_000_000]{custom-style="NormalTok"}  |

    </div>

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                      | Type                                    | Values                                                                       |
|-------------------------------------------|-----------------------------------------|------------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}       | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"}    |
| [\<frequency\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | [10_000]{custom-style="NormalTok"} to [10_000_000]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"}   | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}                          |

</div>

## SPI:FREQuency? {.unnumbered #spi-frequency-query}

#### Syntax {-}

[SPI\<bus\>:FREQuency?]{custom-style="ControlFlowTok"}

:   This query returns bus clock frequency for specified bus.
Also returns minimum, default and maximum frequency when keyword parameter applied.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                                                    |
|-----------------------------------------|-----------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1) | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<keyword\>]{custom-style="NormalTok"} | [[CPD]{custom-style="NormalTok"}](#cpd) | [MINimum/MAXimum/DEFault]{custom-style="NormalTok"}                       |

</div>

#### Returned Query Format {-}

[[\<NR1\>]{custom-style="NormalTok"}](#nr1)

#### Example {-}

`SPI0:FREQuency?` [// Returns SPI0 bus clock frequency in integer]{custom-style="CommentTok"}

:   Typical Response: [5_000_000]{custom-style="StringTok"}

## SPI:TRANSfer {.unnumbered #spi-transfer}

#### Syntax {-}

[SPI\<bus\>:TRANSfer \<data\>,\<pre_cs\>,\<post_cs\>]{custom-style="ControlFlowTok"}

:   This command sends a stream of hexadecimal data and returns what it reads from selected slave device
at the same time. Also, it configures chip select pin for pre and post of data transfer respectively.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                                   | Values                                                                    |
|-----------------------------------------|--------------------------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1)                | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<data\>]{custom-style="NormalTok"}    | [[\<NR4\>\[\<NR4\>\]]{custom-style="NormalTok"}](#nr4) | Stream of data                                                            |
| [\<pre_cs\>]{custom-style="NormalTok"}  | [[Bool]{custom-style="NormalTok"}](#bool)              | Logical value of CS pin.                                                  |
| [\<post_cs\>]{custom-style="NormalTok"} | [[Bool]{custom-style="NormalTok"}](#bool)              | Logical value of CS pin.                                                  |

</div>

#### Returned Query Format {-}

[[\<NR4\>\[,\<NR4\>\]]{custom-style="NormalTok"}](#nr4)

#### Example {-}

`SPI0:TRANSfer ABBA,ON,OFF`  [// Writes 2-bytes of data into SPI0 bus. Simultaneously the slave device returns the same size of data. Asserts CS before transfer; de-asserted after transfer]{custom-style="CommentTok"}

:   Typical Response: [BE,EF]{custom-style="StringTok"}

## SPI:WRITE {.unnumbered #spi-write}

#### Syntax {-}

[SPI\<bus\>:WRITE \<data\>,\<pre_cs\>,\<post_cs\>]{custom-style="ControlFlowTok"}

:   This command sends stream of hexadecimal data into selected slave device. Also, it configures chip select pin
for pre and post of data transfer respectively.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                                   | Values                                                                    |
|-----------------------------------------|--------------------------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1)                | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<data\>]{custom-style="NormalTok"}    | [[\<NR4\>\[\<NR4\>\]]{custom-style="NormalTok"}](#nr4) | Stream of data                                                            |
| [\<pre_cs\>]{custom-style="NormalTok"}  | [[Bool]{custom-style="NormalTok"}](#bool)              | Logical value of CS pin.                                                  |
| [\<post_cs\>]{custom-style="NormalTok"} | [[Bool]{custom-style="NormalTok"}](#bool)              | Logical value of CS pin.                                                  |

</div>

## SPI:READ? {.unnumbered #spi-read-query}

#### Syntax {-}

[SPI\<bus\>:READ? \<length\>,\<mask\>,\<pre_cs\>,\<post_cs\>]{custom-style="ControlFlowTok"}

:   This query returns comma separated list of hexadecimal data from selected slave device.
Also, it configures chip select pin for pre and post of data transfer respectively.

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                      | Values                                                                    |
|-----------------------------------------|-------------------------------------------|---------------------------------------------------------------------------|
| [\<bus\>]{custom-style="NormalTok"}     | [[NR1]{custom-style="NormalTok"}](#nr1)   | Bus number [0]{custom-style="NormalTok"} or [1]{custom-style="NormalTok"} |
| [\<length\>]{custom-style="NormalTok"}  | [[NR1]{custom-style="NormalTok"}](#nr1)   |                                                                           |
| [\<mask\>]{custom-style="NormalTok"}    | [[NR1]{custom-style="NormalTok"}](#nr1)   |                                                                           |
| [\<pre_cs\>]{custom-style="NormalTok"}  | [[Bool]{custom-style="NormalTok"}](#bool) | Logical value of CS pin.                                                  |
| [\<post_cs\>]{custom-style="NormalTok"} | [[Bool]{custom-style="NormalTok"}](#bool) | Logical value of CS pin.                                                  |

</div>

#### Returned Query Format {-}

[[\<NR4\>\[,\<NR4\>\]]{custom-style="NormalTok"}](#nr4)

#### Example {-}

`SPI0:READ? 1,AA` [// Returns a byte of data]{custom-style="CommentTok"}

:   Typical Response: [DE]{custom-style="StringTok"}

# ADC Subsystem {.subsection-toc}

## ADC:READ? {.unnumbered #adc-read-query}

#### Syntax {-}

[ADC\<channel\>:READ?]{custom-style="ControlFlowTok"}

:   This query returns ADC conversion value in range of 0 to 65535

#### Parameter {-}

<div class="table" width="[0.22,0.23,0.55]">

| Item                                    | Type                                    | Values                                |
|-----------------------------------------|-----------------------------------------|---------------------------------------|
| [\<channel\>]{custom-style="NormalTok"} | [[NR1]{custom-style="NormalTok"}](#nr1) | [0/1/2/3/4]{custom-style="NormalTok"} |

</div>

#### Returned Query Format {-}

[[\<NR1\>]{custom-style="NormalTok"}](#nr1)

#### Example {-}

`ADC2:READ?` [// Returns voltage at ADC2 in 16bit unsigned integer]{custom-style="CommentTok"}

:   Typical Response: [12_345]{custom-style="StringTok"}

# IEEE-488.2 Common Commands {#ieee4882-common-commands .subsection-toc}

## \*IDN? {.unnumbered #idn-query}

#### Syntax {-}

[*IDN?]{custom-style="ControlFlowTok"}

:   This command reads the instrument's identification string which contains four
comma-separated fields. The first field is the manufacturer's name, the second is
the model number of the instrument, the third is the serial number, and the fourth
is the firmware revision in [x.y.z]{custom-style="PreprocessorTok"} style.

#### Returned Query Format {-}

[[\<SRD\>]{custom-style="NormalTok"}](#srd)

#### Example {-}

`*IDN?` [// Returns the instrument's identification string]{custom-style="CommentTok"}

:   Typical Response: [RaspberryPiPico,RP001,{serial},0.0.1]{custom-style="StringTok"}

## \*RST {.unnumbered #rst}

#### Syntax {-}

[*RST]{custom-style="ControlFlowTok"}

:   This command resets the target device, including System clock,
GPIO mode and state, I2C and SPI bus clock, SPI chip select pin polarity and state.

#### Example {-}

`*RST` [// Resets the target device including CPU clock.]{custom-style="CommentTok"}

:   Typical Response: [Soft reset]{custom-style="StringTok"}

# あとがき {-}

- いま25日なんですが、闇落ちことEdge of Darkness版にアップデートしてるのに、
  **Escape from Tarkov Arena 招待がまだ来てません**。悲しすぎます。
- Pandocの公式Dockerイメージ更新が遅れてきてるのでDOCX形式にチャレンジしてみた。`pandoc/latex`2.19版使用です。

\newpage
