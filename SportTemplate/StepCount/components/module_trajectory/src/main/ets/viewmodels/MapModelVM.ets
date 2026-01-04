import { ChildSportType, MonthItemModel, SportItemTarget, SportType, TargetType } from '../model/SportModel';
import { Location } from '../types/Types';
import { map, mapCommon } from '@kit.MapKit';
import {
  SELECT_DISTANCE_DEFAULT,
  SELECT_DISTANCE_GE_10,
  SELECT_DISTANCE_L_1,
  SELECT_DISTANCE_L_10,
  SELECT_DISTANCE_L_5,
  SELECT_LENGTH_DEFAULT,
  SELECT_LENGTH_G_10,
  SELECT_LENGTH_GE5_LE10,
  SELECT_LENGTH_L_3,
  SELECT_LENGTH_L_5
} from '../common/TrajectoryConstants';
import { geoLocationManager } from '@kit.LocationKit';
import { MapPublicLogic } from './MapPublicLogic';
import { hilog } from '@kit.PerformanceAnalysisKit';

@ObservedV2
export class MapModelViewModel {
  locusPoints: mapCommon.LatLng[] = [
    { 'latitude': 31.21753369730676, 'longitude': 121.46433714831035 },
    { 'latitude': 31.21590040793166, 'longitude': 121.46472361019309 },
    { 'latitude': 31.21524302414583, 'longitude': 121.46496376898193 },
    { 'latitude': 31.2149351595735, 'longitude': 121.46518072232608 },
    { 'latitude': 31.21510009630907, 'longitude': 121.46569765239164 },
    { 'latitude': 31.21527789043657, 'longitude': 121.46729651684541 },
    { 'latitude': 31.21567502824728, 'longitude': 121.46920907143155 },
    { 'latitude': 31.21574738655144, 'longitude': 121.4702293975031 },
    { 'latitude': 31.21556170553488, 'longitude': 121.47061979395216 },
    { 'latitude': 31.21566971379727, 'longitude': 121.47102805617393 },
    { 'latitude': 31.21558446633652, 'longitude': 121.47184772903087 },
    { 'latitude': 31.21584217520639, 'longitude': 121.47258616327813 },
    { 'latitude': 31.21586590481577, 'longitude': 121.47315439333183 },
    { 'latitude': 31.21619960062377, 'longitude': 121.47462140273841 },
    { 'latitude': 31.21608824291743, 'longitude': 121.47477410867173 },
    { 'latitude': 31.21549340061082, 'longitude': 121.47506034748248 },
    { 'latitude': 31.21516574144564, 'longitude': 121.47506181456566 },
    { 'latitude': 31.21406376485808, 'longitude': 121.47534471797171 },
    { 'latitude': 31.21358811556206, 'longitude': 121.4755781313961 },
    { 'latitude': 31.2129274997196, 'longitude': 121.47565353328259 },
    { 'latitude': 31.21222199938795, 'longitude': 121.47552797399846 },
    { 'latitude': 31.21163545839537, 'longitude': 121.47584989312551 },
    { 'latitude': 31.21025309029512, 'longitude': 121.4760392665612 },
    { 'latitude': 31.20923683635301, 'longitude': 121.47662190391348 },
    { 'latitude': 31.20823063335414, 'longitude': 121.4768887553527 },
    { 'latitude': 31.2076329878678, 'longitude': 121.47727973761176 },
    { 'latitude': 31.20666750808995, 'longitude': 121.47732231632544 },
    { 'latitude': 31.20617990778448, 'longitude': 121.47749381742637 },
    { 'latitude': 31.20588175918661, 'longitude': 121.4776428073128 },
    { 'latitude': 31.20563742237419, 'longitude': 121.47790692605909 },
    { 'latitude': 31.20499559462232, 'longitude': 121.47813353131958 },
    { 'latitude': 31.2046213817056, 'longitude': 121.47843800342875 },
    { 'latitude': 31.20406997842865, 'longitude': 121.47768182436644 },
    { 'latitude': 31.20364898374471, 'longitude': 121.47642226612073 },
    { 'latitude': 31.20347724204475, 'longitude': 121.47562421276822 },
    { 'latitude': 31.20319761256841, 'longitude': 121.47535993299348 },
    { 'latitude': 31.20316439898118, 'longitude': 121.47517143114815 },
    { 'latitude': 31.20223047605186, 'longitude': 121.47523534700366 },
    { 'latitude': 31.2010509857276, 'longitude': 121.47557914785659 },
    { 'latitude': 31.20026237078908, 'longitude': 121.47600162669932 },
    { 'latitude': 31.19947702898693, 'longitude': 121.47617270966271 },
    { 'latitude': 31.1993408848674, 'longitude': 121.47608996375846 },
    { 'latitude': 31.19910888362296, 'longitude': 121.47454816165186 },
    { 'latitude': 31.19868302044374, 'longitude': 121.47316338338266 },
    { 'latitude': 31.19849856386907, 'longitude': 121.47280578369412 },
    { 'latitude': 31.19839335632457, 'longitude': 121.47221162063512 },
    { 'latitude': 31.19778240825129, 'longitude': 121.47012446502662 },
    { 'latitude': 31.19771152830977, 'longitude': 121.46958867850841 },
    { 'latitude': 31.19729847376804, 'longitude': 121.46913241461356 },
    { 'latitude': 31.1969987458958, 'longitude': 121.46924445253958 },
    { 'latitude': 31.19663121835188, 'longitude': 121.4695813074843 },
    { 'latitude': 31.19581152235553, 'longitude': 121.4696979848788 },
    { 'latitude': 31.19512396038664, 'longitude': 121.46966811566049 },
    { 'latitude': 31.19428180635147, 'longitude': 121.46864800297675 },
    { 'latitude': 31.19407984762797, 'longitude': 121.4678263248479 },
    { 'latitude': 31.19379792441417, 'longitude': 121.4674145143509 },
    { 'latitude': 31.19365246357127, 'longitude': 121.46745079508411 },
    { 'latitude': 31.19349683260858, 'longitude': 121.46669748779778 },
    { 'latitude': 31.19321832073036, 'longitude': 121.46611106734694 },
    { 'latitude': 31.19264369453581, 'longitude': 121.46534063723675 },
    { 'latitude': 31.19254573823262, 'longitude': 121.46526055824614 },
    { 'latitude': 31.19242396703299, 'longitude': 121.46543195628496 },
    { 'latitude': 31.1923177432287, 'longitude': 121.46500247651791 },
    { 'latitude': 31.19192539731521, 'longitude': 121.46435179241579 },
    { 'latitude': 31.19092460920296, 'longitude': 121.46315765987765 },
    { 'latitude': 31.18949515263385, 'longitude': 121.46086941191271 },
    { 'latitude': 31.18920573569284, 'longitude': 121.46054685514127 },
    { 'latitude': 31.188622979572, 'longitude': 121.45941003191093 },
    { 'latitude': 31.18766767356631, 'longitude': 121.45786687496828 },
    { 'latitude': 31.18728242082524, 'longitude': 121.45696115881155 },
    { 'latitude': 31.18693286971142, 'longitude': 121.45518277814171 },
    { 'latitude': 31.18676413800524, 'longitude': 121.45471900175165 },
    { 'latitude': 31.18675844620368, 'longitude': 121.45417302931377 },
    { 'latitude': 31.18620455027981, 'longitude': 121.4526813434135 },
    { 'latitude': 31.1858146253425, 'longitude': 121.45136058128156 },
    { 'latitude': 31.18531072794655, 'longitude': 121.45033277363281 },
    { 'latitude': 31.18475404458943, 'longitude': 121.44947783183127 },
    { 'latitude': 31.18125212363582, 'longitude': 121.44532849730039 },
    { 'latitude': 31.18074103275121, 'longitude': 121.44432754590943 },
    { 'latitude': 31.18022000117398, 'longitude': 121.44375761381043 },
    { 'latitude': 31.17994744318488, 'longitude': 121.44327392244829 },
    { 'latitude': 31.17952822376704, 'longitude': 121.4428395136193 },
    { 'latitude': 31.17920858781025, 'longitude': 121.44218641263258 },
    { 'latitude': 31.17830846567249, 'longitude': 121.44105650714581 },
    { 'latitude': 31.17810610144332, 'longitude': 121.44063125324174 },
    { 'latitude': 31.17815171740385, 'longitude': 121.44016338698121 },
    { 'latitude': 31.17935087963807, 'longitude': 121.43852191554796 },
    { 'latitude': 31.17931050491556, 'longitude': 121.43848936667237 },
    { 'latitude': 31.17942621838965, 'longitude': 121.43852132308863 },
    { 'latitude': 31.17932643843334, 'longitude': 121.43832793821745 },
    { 'latitude': 31.18059657835724, 'longitude': 121.43617462559871 },
    { 'latitude': 31.18121180932589, 'longitude': 121.43383748374675 },
    { 'latitude': 31.18149226396839, 'longitude': 121.43357448482433 },
    { 'latitude': 31.18190273513974, 'longitude': 121.43292233906888 },
    { 'latitude': 31.18250157744929, 'longitude': 121.432185502313 },
    { 'latitude': 31.18338076859462, 'longitude': 121.43132702107421 },
    { 'latitude': 31.18404250966345, 'longitude': 121.43047637237808 },
    { 'latitude': 31.18478518703938, 'longitude': 121.4296963065091 },
    { 'latitude': 31.18543659775473, 'longitude': 121.42870504886562 },
    { 'latitude': 31.18691039972688, 'longitude': 121.42768564221664 },
    { 'latitude': 31.18789072226939, 'longitude': 121.4267638336216 },
    { 'latitude': 31.18829074905024, 'longitude': 121.42650444339859 },
    { 'latitude': 31.18866703537847, 'longitude': 121.42639009622054 },
    { 'latitude': 31.18947177156395, 'longitude': 121.425642034624 },
    { 'latitude': 31.19021348113471, 'longitude': 121.42510453285625 },
    { 'latitude': 31.19054733549308, 'longitude': 121.42499416958473 },
    { 'latitude': 31.19068200204549, 'longitude': 121.42486970195776 },
    { 'latitude': 31.19125380930154, 'longitude': 121.42545397819027 },
    { 'latitude': 31.19205103214876, 'longitude': 121.42647869773868 },
    { 'latitude': 31.19230322448525, 'longitude': 121.42651538106824 },
    { 'latitude': 31.19243426568309, 'longitude': 121.42642758478403 },
    { 'latitude': 31.19298578102906, 'longitude': 121.42481695336087 },
    { 'latitude': 31.19322385469141, 'longitude': 121.42423542519365 },
    { 'latitude': 31.19337124636561, 'longitude': 121.4240803819067 },
    { 'latitude': 31.19360693157389, 'longitude': 121.42290295315774 },
    { 'latitude': 31.19373256361859, 'longitude': 121.42280394906541 },
    { 'latitude': 31.19455018674479, 'longitude': 121.42248798791187 },
    { 'latitude': 31.19525562843827, 'longitude': 121.42234976474327 },
    { 'latitude': 31.19636810777567, 'longitude': 121.42185536604958 },
    { 'latitude': 31.19654670344924, 'longitude': 121.42184299155444 },
    { 'latitude': 31.19669276576497, 'longitude': 121.42200657200905 },
    { 'latitude': 31.19681594311692, 'longitude': 121.42183112453555 },
    { 'latitude': 31.19726696026382, 'longitude': 121.4215318019209 },
    { 'latitude': 31.19821567241378, 'longitude': 121.42161072220955 },
    { 'latitude': 31.19856684348496, 'longitude': 121.42130179481836 },
    { 'latitude': 31.19872591501295, 'longitude': 121.42131130129777 },
    { 'latitude': 31.19908280503309, 'longitude': 121.42096959430597 },
    { 'latitude': 31.19944200665228, 'longitude': 121.42076537913686 },
    { 'latitude': 31.20046649374436, 'longitude': 121.42045559701416 },
    { 'latitude': 31.20104737269342, 'longitude': 121.41995270785622 },
    { 'latitude': 31.2017192147345, 'longitude': 121.41975090711966 },
    { 'latitude': 31.2025401842742, 'longitude': 121.41962486542388 },
    { 'latitude': 31.20311957421957, 'longitude': 121.41924777051129 },
    { 'latitude': 31.20349987996416, 'longitude': 121.41920803002398 },
    { 'latitude': 31.20529064584256, 'longitude': 121.41804931826403 },
    { 'latitude': 31.20618302159875, 'longitude': 121.41774927389055 },
    { 'latitude': 31.2074722699818, 'longitude': 121.41747794291666 },
    { 'latitude': 31.20785970701262, 'longitude': 121.41714916129365 },
    { 'latitude': 31.20802398821695, 'longitude': 121.41714397846844 },
    { 'latitude': 31.20829971545585, 'longitude': 121.41737407394871 },
    { 'latitude': 31.2086973651647, 'longitude': 121.41746245846135 },
    { 'latitude': 31.21100821989821, 'longitude': 121.41757099764578 },
    { 'latitude': 31.21244534673898, 'longitude': 121.41790222934828 },
    { 'latitude': 31.21294498413008, 'longitude': 121.41810705028447 },
    { 'latitude': 31.21358164859284, 'longitude': 121.41798158112197 },
    { 'latitude': 31.21565925088914, 'longitude': 121.41731324939662 },
    { 'latitude': 31.2164462415994, 'longitude': 121.41748941821762 },
    { 'latitude': 31.21694659648272, 'longitude': 121.41744978440597 },
    { 'latitude': 31.21733802579917, 'longitude': 121.4177787285015 },
    { 'latitude': 31.21767591981299, 'longitude': 121.41770640022361 },
    { 'latitude': 31.21781134410574, 'longitude': 121.41778906368375 },
    { 'latitude': 31.21817498719966, 'longitude': 121.41825401665346 },
    { 'latitude': 31.21873487161852, 'longitude': 121.41971201633644 },
    { 'latitude': 31.21866742660447, 'longitude': 121.41991007274282 },
    { 'latitude': 31.21878603211059, 'longitude': 121.42050405745111 },
    { 'latitude': 31.21866011861521, 'longitude': 121.42107891655042 },
    { 'latitude': 31.21874815376214, 'longitude': 121.42108891658638 },
    { 'latitude': 31.21870981159176, 'longitude': 121.42159452020389 },
    { 'latitude': 31.21931352547764, 'longitude': 121.42185296661347 },
    { 'latitude': 31.21994714009644, 'longitude': 121.42312745267074 },
    { 'latitude': 31.22053107062945, 'longitude': 121.42399562546684 },
    { 'latitude': 31.22081855997268, 'longitude': 121.42418577471836 },
    { 'latitude': 31.22113398316451, 'longitude': 121.42485456852878 },
    { 'latitude': 31.2219527789995, 'longitude': 121.4255748307213 },
    { 'latitude': 31.22245781655634, 'longitude': 121.42616477326716 },
    { 'latitude': 31.22262792911332, 'longitude': 121.4265875456559 },
    { 'latitude': 31.22306837544242, 'longitude': 121.42688097136759 },
    { 'latitude': 31.22400555790741, 'longitude': 121.4279255028501 },
    { 'latitude': 31.22330909134375, 'longitude': 121.42890720839878 },
    { 'latitude': 31.22342122487897, 'longitude': 121.42922973454688 },
    { 'latitude': 31.22420836146404, 'longitude': 121.43004880419265 },
    { 'latitude': 31.22451454468315, 'longitude': 121.43077331776824 },
    { 'latitude': 31.22448672801641, 'longitude': 121.43114973005401 },
    { 'latitude': 31.22398554962067, 'longitude': 121.43155795168654 },
    { 'latitude': 31.22400586558208, 'longitude': 121.43173342093074 },
    { 'latitude': 31.22379732978952, 'longitude': 121.43221545569184 },
    { 'latitude': 31.22350595834418, 'longitude': 121.43242344735577 },
    { 'latitude': 31.22270651059636, 'longitude': 121.43275072791198 },
    { 'latitude': 31.2226387394762, 'longitude': 121.4328715545317 },
    { 'latitude': 31.22277385324547, 'longitude': 121.43367982638504 },
    { 'latitude': 31.22318238783606, 'longitude': 121.43503527421458 },
    { 'latitude': 31.22328550126958, 'longitude': 121.43561650173533 },
    { 'latitude': 31.22321198539306, 'longitude': 121.43575837753177 },
    { 'latitude': 31.22245818445199, 'longitude': 121.43595171343798 },
    { 'latitude': 31.22204782223378, 'longitude': 121.4359287133211 },
    { 'latitude': 31.22155730637037, 'longitude': 121.4360727471861 },
    { 'latitude': 31.22096646302088, 'longitude': 121.43612401596461 },
    { 'latitude': 31.21917443723873, 'longitude': 121.4367973995171 },
    { 'latitude': 31.21831286218341, 'longitude': 121.43737160195271 },
    { 'latitude': 31.21793163458444, 'longitude': 121.43748079143738 },
    { 'latitude': 31.21762619977151, 'longitude': 121.43740019581378 },
    { 'latitude': 31.21743646292513, 'longitude': 121.43758238280295 },
    { 'latitude': 31.21701641959755, 'longitude': 121.43776185252261 },
    { 'latitude': 31.21594624295616, 'longitude': 121.43853457605737 },
    { 'latitude': 31.21594542481519, 'longitude': 121.43868951502237 },
    { 'latitude': 31.21568407861205, 'longitude': 121.43898808598139 },
    { 'latitude': 31.21549138824036, 'longitude': 121.43898747026632 },
    { 'latitude': 31.21485028639049, 'longitude': 121.43926633755181 },
    { 'latitude': 31.21450940796184, 'longitude': 121.43913822748795 },
    { 'latitude': 31.21494722508152, 'longitude': 121.44103922259601 },
    { 'latitude': 31.21507690241499, 'longitude': 121.44207493674885 },
    { 'latitude': 31.21535294517034, 'longitude': 121.44308515932989 },
    { 'latitude': 31.21553731646388, 'longitude': 121.44433086200037 },
    { 'latitude': 31.21500058783692, 'longitude': 121.44485926889827 },
    { 'latitude': 31.21467998308944, 'longitude': 121.44501073858168 },
    { 'latitude': 31.21447767245298, 'longitude': 121.44501950346358 },
    { 'latitude': 31.21404808618097, 'longitude': 121.44542564953064 },
    { 'latitude': 31.21306436897521, 'longitude': 121.44580868666848 },
    { 'latitude': 31.21294390958298, 'longitude': 121.44592713439077 },
    { 'latitude': 31.21245112536509, 'longitude': 121.44607299288478 },
    { 'latitude': 31.21151875201415, 'longitude': 121.44655382007393 },
    { 'latitude': 31.21132330149413, 'longitude': 121.44652915423982 },
    { 'latitude': 31.21074071153484, 'longitude': 121.44670873061237 },
    { 'latitude': 31.21063076450426, 'longitude': 121.44682038835576 },
    { 'latitude': 31.21055816277585, 'longitude': 121.4472011840014 },
    { 'latitude': 31.21050924626315, 'longitude': 121.44781827199511 },
    { 'latitude': 31.21062459872832, 'longitude': 121.44865308447246 },
    { 'latitude': 31.21058616967016, 'longitude': 121.44942339376545 },
    { 'latitude': 31.21067249207395, 'longitude': 121.4499720826697 },
    { 'latitude': 31.21091733505373, 'longitude': 121.4509654627023 },
    { 'latitude': 31.21171871006525, 'longitude': 121.45342858346462 },
    { 'latitude': 31.211824009266, 'longitude': 121.45419953808875 },
    { 'latitude': 31.21252279415186, 'longitude': 121.45663836323931 },
    { 'latitude': 31.21261565834366, 'longitude': 121.45719416054498 },
    { 'latitude': 31.2127431064112, 'longitude': 121.45724693696087 },
    { 'latitude': 31.21355557993663, 'longitude': 121.45706537006326 },
    { 'latitude': 31.21421575903514, 'longitude': 121.45703460554698 },
    { 'latitude': 31.214583051907, 'longitude': 121.45819017077309 },
    { 'latitude': 31.21483644704216, 'longitude': 121.45843196501766 },
    { 'latitude': 31.21515113774542, 'longitude': 121.45964241410362 },
    { 'latitude': 31.2154138714952, 'longitude': 121.46008785244917 },
    { 'latitude': 31.21596162507063, 'longitude': 121.46146548701204 },
    { 'latitude': 31.21611449140883, 'longitude': 121.46177485624659 },
    { 'latitude': 31.21641074818481, 'longitude': 121.46189864314851 },
    { 'latitude': 31.21656996586697, 'longitude': 121.46222855124153 },
    { 'latitude': 31.21698694527992, 'longitude': 121.46258290986702 },
    { 'latitude': 31.21742361971395, 'longitude': 121.4635414796048 },
    { 'latitude': 31.21762225066223, 'longitude': 121.46416314801243 },
    { 'latitude': 31.21722864733102, 'longitude': 121.46429743432085 },
    { 'latitude': 31.21731248929925, 'longitude': 121.46425416397578 }
  ]
  locusPoints1: mapCommon.LatLng[] = [
    { 'latitude': 31.228688162001185, 'longitude': 121.4623013002015 },
    { 'latitude': 31.22770692545744, 'longitude': 121.46264027924341 },
    { 'latitude': 31.226875800334444, 'longitude': 121.46295932234808 },
    { 'latitude': 31.226866212717155, 'longitude': 121.46277981987847 },
    { 'latitude': 31.22693799461325, 'longitude': 121.46202191674676 },
    { 'latitude': 31.22693958961756, 'longitude': 121.46132382298216 },
    { 'latitude': 31.22668258907427, 'longitude': 121.45993752931487 },
    { 'latitude': 31.22651425499608, 'longitude': 121.45914959985994 },
    { 'latitude': 31.226226255642644, 'longitude': 121.45817212668797 },
    { 'latitude': 31.22610693308762, 'longitude': 121.4578329925456 },
    { 'latitude': 31.22598741391857, 'longitude': 121.45758362343539 },
    { 'latitude': 31.22549907883549, 'longitude': 121.45669584302227 },
    { 'latitude': 31.225339552130364, 'longitude': 121.45643648376587 },
    { 'latitude': 31.223838115840834, 'longitude': 121.45678547211819 },
    { 'latitude': 31.223267638299514, 'longitude': 121.45688516990613 },
    { 'latitude': 31.222827390444717, 'longitude': 121.45690508120481 },
    { 'latitude': 31.222827390444717, 'longitude': 121.45690508120481 },
    { 'latitude': 31.222147093702592, 'longitude': 121.45689504767933 },
    { 'latitude': 31.221916922520613, 'longitude': 121.45692495181931 },
    { 'latitude': 31.221526485380416, 'longitude': 121.45704461386791 },
    { 'latitude': 31.22119592672504, 'longitude': 121.45723410243717 },
    { 'latitude': 31.22097543966582, 'longitude': 121.45741362456395 },
    { 'latitude': 31.220624954707926, 'longitude': 121.45756321089923 },
    { 'latitude': 31.22011437226738, 'longitude': 121.45772275681811 },
    { 'latitude': 31.2186626775936, 'longitude': 121.45819142107967 },
    { 'latitude': 31.218482441329183, 'longitude': 121.45826122448156 },
    { 'latitude': 31.218174762572335, 'longitude': 121.45711414630781 },
    { 'latitude': 31.217747210382417, 'longitude': 121.45585727685238 },
    { 'latitude': 31.217597638145637, 'longitude': 121.45561785969306 },
    { 'latitude': 31.216822597381764, 'longitude': 121.45299415981491 },
    { 'latitude': 31.21674291498786, 'longitude': 121.45281457771959 },
    { 'latitude': 31.21681373359147, 'longitude': 121.45241552275373 },
    { 'latitude': 31.216894064435774, 'longitude': 121.45226587997764 },
    { 'latitude': 31.21708508630015, 'longitude': 121.45178701067857 },
    { 'latitude': 31.21717534120202, 'longitude': 121.45167727238076 },
    { 'latitude': 31.216936606850272, 'longitude': 121.45095890015089 },
    { 'latitude': 31.216499097991246, 'longitude': 121.44952208900782 },
    { 'latitude': 31.216111029923876, 'longitude': 121.44836458584406 },
    { 'latitude': 31.216111029923876, 'longitude': 121.44836458584406 },
    { 'latitude': 31.216081195734553, 'longitude': 121.44826479849619 },
    { 'latitude': 31.215922687220996, 'longitude': 121.44738665881301 },
    { 'latitude': 31.215883055341752, 'longitude': 121.44716711824544 },
    { 'latitude': 31.21574312933439, 'longitude': 121.44708727386776 },
    { 'latitude': 31.215192535210416, 'longitude': 121.44727682723143 },
    { 'latitude': 31.2151525514293, 'longitude': 121.44725686583444 },
    { 'latitude': 31.214983379949285, 'longitude': 121.44673793838302 },
    { 'latitude': 31.21474307470143, 'longitude': 121.44684768862013 },
    { 'latitude': 31.21451414122509, 'longitude': 121.44616907482446 },
    { 'latitude': 31.214374961389804, 'longitude': 121.44565012321237 },
    { 'latitude': 31.213888551775213, 'longitude': 121.4433346547198 },
    { 'latitude': 31.213888551775213, 'longitude': 121.4433346547198 },
    { 'latitude': 31.213541016816595, 'longitude': 121.4416577736994 },
    { 'latitude': 31.213242682191876, 'longitude': 121.44045991223542 },
    { 'latitude': 31.213162969091037, 'longitude': 121.44024029438739 },
    { 'latitude': 31.213073205282292, 'longitude': 121.44005062067329 },
    { 'latitude': 31.212942923269186, 'longitude': 121.44020034576458 },
    { 'latitude': 31.212231919032334, 'longitude': 121.44064948653647 },
    { 'latitude': 31.212231919032334, 'longitude': 121.44064948653647 },
    { 'latitude': 31.211851379164244, 'longitude': 121.44088902406177 },
    { 'latitude': 31.211601109741984, 'longitude': 121.44098882256234 },
    { 'latitude': 31.211350900134608, 'longitude': 121.44104869274146 },
    { 'latitude': 31.210940674224833, 'longitude': 121.44106862106035 },
    { 'latitude': 31.210770638202646, 'longitude': 121.44103866040413 },
    { 'latitude': 31.208290464917273, 'longitude': 121.44035965947773 },
    { 'latitude': 31.207200543515274, 'longitude': 121.43995028594059 },
    { 'latitude': 31.204451861114347, 'longitude': 121.43809321286869 },
    { 'latitude': 31.204321894904812, 'longitude': 121.43802331731988 },
    { 'latitude': 31.204321894904812, 'longitude': 121.43802331731988 },
    { 'latitude': 31.204181937393564, 'longitude': 121.43794343713396 },
    { 'latitude': 31.20395190862265, 'longitude': 121.43788351592306 },
    { 'latitude': 31.20137841214331, 'longitude': 121.43948059683275 },
    { 'latitude': 31.199345799360803, 'longitude': 121.44058847505735 },
    { 'latitude': 31.19996276075549, 'longitude': 121.44276453051034 },
    { 'latitude': 31.200022267176557, 'longitude': 121.4430939101546 },
    { 'latitude': 31.200051914772725, 'longitude': 121.44332347362564 },
    { 'latitude': 31.200479060230112, 'longitude': 121.44518984569001 },
    { 'latitude': 31.200777971839187, 'longitude': 121.44591839540436 },
    { 'latitude': 31.201206263325624, 'longitude': 121.44702613950631 },
    { 'latitude': 31.201494473891746, 'longitude': 121.44811385650565 },
    { 'latitude': 31.201494366284344, 'longitude': 121.44817372784521 },
    { 'latitude': 31.20162363601294, 'longitude': 121.44861279050638 },
    { 'latitude': 31.20192270598141, 'longitude': 121.44920153048759 },
    { 'latitude': 31.202112153722307, 'longitude': 121.44955077650595 },
    { 'latitude': 31.202670746554848, 'longitude': 121.45044881822136 },
    { 'latitude': 31.202840224623486, 'longitude': 121.45076811056751 },
    { 'latitude': 31.20298965096131, 'longitude': 121.45110735097485 },
    { 'latitude': 31.203396552799873, 'longitude': 121.45280344614219 },
    { 'latitude': 31.203575590203208, 'longitude': 121.45333220716055 },
    { 'latitude': 31.20502637238559, 'longitude': 121.45810047501824 },
    { 'latitude': 31.205434042021757, 'longitude': 121.45925748954313 },
    { 'latitude': 31.205792044503742, 'longitude': 121.46023492644968 },
    { 'latitude': 31.20651837204369, 'longitude': 121.46201018118824 },
    { 'latitude': 31.206756923334176, 'longitude': 121.46268833284705 },
    { 'latitude': 31.207274119035507, 'longitude': 121.46399472801198 },
    { 'latitude': 31.20766205832071, 'longitude': 121.46494207528293 },
    { 'latitude': 31.208319085314184, 'longitude': 121.46630820085989 },
    { 'latitude': 31.20849834661396, 'longitude': 121.46664723042197 },
    { 'latitude': 31.21032040635644, 'longitude': 121.46615880701658 },
    { 'latitude': 31.210991040555957, 'longitude': 121.46602924002942 },
    { 'latitude': 31.2117518854004, 'longitude': 121.46582988169437 },
    { 'latitude': 31.2117518854004, 'longitude': 121.46582988169437 },
    { 'latitude': 31.213894414965317, 'longitude': 121.46520187178494 },
    { 'latitude': 31.21488533821303, 'longitude': 121.46501249892962 },
    { 'latitude': 31.21882970886818, 'longitude': 121.46395583726412 },
    { 'latitude': 31.220161225264242, 'longitude': 121.46357701693581 },
    { 'latitude': 31.22127221314525, 'longitude': 121.46337767108227 },
    { 'latitude': 31.22146241876409, 'longitude': 121.46332782683278 },
    { 'latitude': 31.22268336219237, 'longitude': 121.46316837746466 },
    { 'latitude': 31.222843390427737, 'longitude': 121.46318833567512 },
    { 'latitude': 31.222843367158045, 'longitude': 121.46319830786576 },
    { 'latitude': 31.222843367158045, 'longitude': 121.46319830786576 },
    { 'latitude': 31.222843390427737, 'longitude': 121.46318833567512 },
    { 'latitude': 31.222913376587876, 'longitude': 121.46320828609796 },
    { 'latitude': 31.224143787506673, 'longitude': 121.46327819752631 },
    { 'latitude': 31.224714122881863, 'longitude': 121.46324833026231 },
    { 'latitude': 31.22518448124835, 'longitude': 121.46318853777111 },
    { 'latitude': 31.226275173727974, 'longitude': 121.46310885426383 },
    { 'latitude': 31.226875800334444, 'longitude': 121.46295932234808 },
    { 'latitude': 31.227706925457436, 'longitude': 121.46264027924341 },
    { 'latitude': 31.228838346179124, 'longitude': 121.46225145048242 }
  ]
  routeData: MonthItemModel[] = [
    new MonthItemModel(9, 1, SportType.WALKING, ChildSportType.TARGET_WALKING, 10, 30, 10000, 720,
      {
        targetType: TargetType.DISTANCE,
        value: 10000
      } as SportItemTarget, 100, 1250, this.locusPoints, 2025),
    new MonthItemModel(9, 2, SportType.WALKING, ChildSportType.TARGET_WALKING, 16, 15, 12000, 660,
      {
        targetType: TargetType.DISTANCE,
        value: 11000
      } as SportItemTarget, 100, 1250, this.locusPoints1, 2025)]
  @Trace nameItem: Map<number, string> = new Map()
  @Trace currentType: MonthItemModel[] = []
  @Trace distanceMap: Map<number, string> = new Map()
  selectDistance: string = SELECT_DISTANCE_DEFAULT;
  selectLength: string = SELECT_LENGTH_DEFAULT;
  originalList: MonthItemModel[] = []

  removeByIndexList(indexList: number[]): MonthItemModel[] {
    let temporary: MonthItemModel[] = []
    let deleteList: MonthItemModel[] = []
    this.currentType.forEach((item: MonthItemModel, index: number) => {
      if (indexList.indexOf(index) === -1) {
        temporary.push(item)
      } else {
        deleteList.push(item)
      }
    })
    this.currentType = []
    setTimeout(() => {
      this.currentType = temporary
    }, 10)
    return deleteList
  }

  async currentTypeAddData(place: Location[]): Promise<MonthItemModel> {
    let nowData: Date = new Date()
    let allDistance: number = 0
    for (let index = 0; index < place.length - 1; index++) {
      let distance = map.calculateDistance(place[index], place[index + 1]);
      allDistance += distance
    }
    let month: MonthItemModel =
      new MonthItemModel(nowData.getMonth(), nowData.getDay(), SportType.JOGGING, ChildSportType.TARGET_JOGGING, 12, 30,
        Math.trunc(allDistance), 660,
        {
          targetType: TargetType.DISTANCE,
          value: 11000
        } as SportItemTarget, Math.trunc(allDistance / 10), Math.trunc(allDistance) / 2, place, nowData.getFullYear())
    this.currentType.push(month)
    let addName: string = await MapPublicLogic.getPoi(place[0].latitude, place[0].longitude)
    this.nameItem.set(Math.trunc(allDistance) + Math.trunc(allDistance) / 2, addName)
    return month
  }

  async init(currentType: MonthItemModel[]) {
    this.currentType = currentType.filter(item => item.locusPoints !== undefined);
    this.currentType.forEach(async (item: MonthItemModel, index: number) => {
      let addName: string = ''
      if (item.locusPoints) {
        addName = await MapPublicLogic.getPoi(item.locusPoints[0].latitude, item.locusPoints[0].longitude)
      }
      this.nameItem.set(item.distance + item.stepCount, addName)
    })
    await this.computeDistance(this.currentType)
    this.originalList = [...this.currentType]
  }

  async select() {
    try {
      geoLocationManager.getCurrentLocation().then(async (location) => {
        if (location) {
          const promises = this.originalList.map(async (item) => {
            if (item.locusPoints && item.toDistance === undefined) {
              item.toDistance = Number((map.calculateDistance(location,
                { latitude: item.locusPoints[0].latitude, longitude: item.locusPoints[0].longitude }) /
                1000).toFixed(1));
            }
          });

          await Promise.all(promises);

          this.applyFilters();
        }
      });
    } catch (error) {
      hilog.error(0x0000, 'MapModelViewModel', 'getCurrentLocation error');
    }
  }

  private applyFilters() {
    let tempList = [...this.originalList];

    // 第一级过滤
    tempList = this.applyLengthFilter(tempList);

    // 第二级过滤
    tempList = this.applyDistanceFilter(tempList);

    this.currentType = [...tempList];
  }

  private applyLengthFilter(list: MonthItemModel[]): MonthItemModel[] {
    switch (this.selectLength) {
      case SELECT_LENGTH_L_3:
        return list.filter(item => item.distance / 1000 < 3);
      case SELECT_LENGTH_L_5:
        return list.filter(item => item.distance / 1000 > 3 && item.distance / 1000 <= 5);
      case SELECT_LENGTH_GE5_LE10:
        return list.filter(item => item.distance / 1000 > 5 && item.distance / 1000 <= 10);
      case SELECT_LENGTH_G_10:
        return list.filter(item => item.distance / 1000 > 10);
      default:
        return list.filter(item => item.distance !== undefined);
    }
  }

  private applyDistanceFilter(list: MonthItemModel[]): MonthItemModel[] {
    switch (this.selectDistance) {
      case SELECT_DISTANCE_L_1:
        return list.filter(item => item.toDistance! < 1);
      case SELECT_DISTANCE_L_5:
        return list.filter(item => item.toDistance! < 5);
      case SELECT_DISTANCE_L_10:
        return list.filter(item => item.toDistance! < 10);
      case SELECT_DISTANCE_GE_10:
        return list.filter(item => item.toDistance! >= 10);
      default:
        return list.sort((a, b) => Number(a.toDistance) - Number(b.toDistance));
    }
  }

  computeDistance(month: MonthItemModel[]) {
    month.forEach(async (item: MonthItemModel, index: number) => {
      if (item.locusPoints) {
        let distance: string =
          (await MapPublicLogic.distanceBetween(item.locusPoints[0].latitude,
            item.locusPoints[0].longitude) / 1000).toFixed(1)
        this.distanceMap.set(item.distance + item.stepCount, distance)
      }
    })
  }
}