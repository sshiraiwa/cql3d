
c
c
      subroutine micfrplt
      implicit integer (i-n), real*8 (a-h,o-z)
      save

      character*8 textt
      common /plttextt/ textt(200)

      textt(1)="1$"
      textt(2)="2$"
      textt(3)="3$"
      textt(4)="4$"
      textt(5)="5$"
      textt(6)="6$"
      textt(7)="7$"
      textt(8)="8$"
      textt(9)="9$"
      textt(10)="10$"
      textt(11)="11$"
      textt(12)="12$"
      textt(13)="13$"
      textt(14)="14$"
      textt(15)="15$"
      textt(16)="16$"
      textt(17)="17$"
      textt(18)="18$"
      textt(19)="19$"
      textt(20)="20$"
      textt(21)="21$"
      textt(22)="22$"
      textt(23)="23$"
      textt(24)="24$"
      textt(25)="25$"
      textt(26)="26$"
      textt(27)="27$"
      textt(28)="28$"
      textt(29)="29$"
      textt(30)="30$"
      textt(31)="31$"
      textt(32)="32$"
      textt(33)="33$"
      textt(34)="34$"
      textt(35)="35$"
      textt(36)="36$"
      textt(37)="37$"
      textt(38)="38$"
      textt(39)="39$"
      textt(40)="40$"
      textt(41)="41$"
      textt(42)="42$"
      textt(43)="43$"
      textt(44)="44$"
      textt(45)="45$"
      textt(46)="46$"
      textt(47)="47$"
      textt(48)="48$"
      textt(49)="49$"
      textt(50)="50$"
      textt(51)="51$"
      textt(52)="52$"
      textt(53)="53$"
      textt(54)="54$"
      textt(55)="55$"
      textt(56)="56$"
      textt(57)="57$"
      textt(58)="58$"
      textt(59)="59$"
      textt(60)="60$"
      textt(61)="61$"
      textt(62)="62$"
      textt(63)="63$"
      textt(64)="64$"
      textt(65)="65$"
      textt(66)="66$"
      textt(67)="67$"
      textt(68)="68$"
      textt(69)="69$"
      textt(70)="70$"
      textt(71)="71$"
      textt(72)="72$"
      textt(73)="73$"
      textt(74)="74$"
      textt(75)="75$"
      textt(76)="76$"
      textt(77)="77$"
      textt(78)="78$"
      textt(79)="79$"
      textt(80)="80$"
      textt(81)="81$"
      textt(82)="82$"
      textt(83)="83$"
      textt(84)="84$"
      textt(85)="85$"
      textt(86)="86$"
      textt(87)="87$"
      textt(88)="88$"
      textt(89)="89$"
      textt(90)="90$"
      textt(91)="91$"
      textt(92)="92$"
      textt(93)="93$"
      textt(94)="94$"
      textt(95)="95$"
      textt(96)="96$"
      textt(97)="97$"
      textt(98)="98$"
      textt(99)="99$"
      textt(100)="100$"
      textt(101)="101$"
      textt(102)="102$"
      textt(103)="103$"
      textt(104)="104$"
      textt(105)="105$"
      textt(106)="106$"
      textt(107)="107$"
      textt(108)="108$"
      textt(109)="109$"
      textt(110)="110$"
      textt(111)="111$"
      textt(112)="112$"
      textt(113)="113$"
      textt(114)="114$"
      textt(115)="115$"
      textt(116)="116$"
      textt(117)="117$"
      textt(118)="118$"
      textt(119)="119$"
      textt(120)="120$"
      textt(121)="121$"
      textt(122)="122$"
      textt(123)="123$"
      textt(124)="124$"
      textt(125)="125$"
      textt(126)="126$"
      textt(127)="127$"
      textt(128)="128$"
      textt(129)="129$"
      textt(130)="130$"
      textt(131)="131$"
      textt(132)="132$"
      textt(133)="133$"
      textt(134)="134$"
      textt(135)="135$"
      textt(136)="136$"
      textt(137)="137$"
      textt(138)="138$"
      textt(139)="139$"
      textt(140)="140$"
      textt(141)="141$"
      textt(142)="142$"
      textt(143)="143$"
      textt(144)="144$"
      textt(145)="145$"
      textt(146)="146$"
      textt(147)="147$"
      textt(148)="148$"
      textt(149)="149$"
      textt(150)="150$"
      textt(151)="151$"
      textt(152)="152$"
      textt(153)="153$"
      textt(154)="154$"
      textt(155)="155$"
      textt(156)="156$"
      textt(157)="157$"
      textt(158)="158$"
      textt(159)="159$"
      textt(160)="160$"
      textt(161)="161$"
      textt(162)="162$"
      textt(163)="163$"
      textt(164)="164$"
      textt(165)="165$"
      textt(166)="166$"
      textt(167)="167$"
      textt(168)="168$"
      textt(169)="169$"
      textt(170)="170$"
      textt(171)="171$"
      textt(172)="172$"
      textt(173)="173$"
      textt(174)="174$"
      textt(175)="175$"
      textt(176)="176$"
      textt(177)="177$"
      textt(178)="178$"
      textt(179)="179$"
      textt(180)="180$"
      textt(181)="181$"
      textt(182)="182$"
      textt(183)="183$"
      textt(184)="184$"
      textt(185)="185$"
      textt(186)="186$"
      textt(187)="187$"
      textt(188)="188$"
      textt(189)="189$"
      textt(190)="190$"
      textt(191)="191$"
      textt(192)="192$"
      textt(193)="193$"
      textt(194)="194$"
      textt(195)="195$"
      textt(196)="196$"
      textt(197)="197$"
      textt(198)="198$"
      textt(199)="199$"
      textt(200)="200$"
      return
      end
